<?php
/**
 * Cliente Oficial para la API de QvaPay (AstroIO Banco v1.0)
 * Maneja toda la comunicación con los servidores de QvaPay.
 * v1.1 — Añadido getP2PAverages() para tasa real automática (Fase 3)
 */

class QvaPayException extends Exception {}

class QvaPay 
{
    private $appId;
    private $appSecret;
    private $baseUrl = 'https://api.qvapay.com';
    private $timeout = 20;

    public function __construct($appId, $appSecret) 
    {
        $this->appId     = $appId;
        $this->appSecret = $appSecret;

        if (empty($this->appId) || empty($this->appSecret)) {
            throw new QvaPayException("Las credenciales de QvaPay (App ID / Secret) no están configuradas.");
        }
    }

    /**
     * Petición base usando cURL.
     * QvaPay usa app-id y app-secret en los headers para autenticación server-to-server.
     * Para endpoints públicos (como /p2p/averages) los headers son ignorados.
     */
    private function request($endpoint, $data = [], $method = 'POST') 
    {
        $ch = curl_init($this->baseUrl . $endpoint);
        
        $headers = [
            'Content-Type: application/json',
            'Accept: application/json',
            'app-id: ' . $this->appId,
            'app-secret: ' . $this->appSecret
        ];

        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT        => $this->timeout,
            CURLOPT_HTTPHEADER     => $headers,
            CURLOPT_SSL_VERIFYPEER => true
        ]);

        if ($method === 'POST') {
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        } elseif ($method === 'GET') {
            curl_setopt($ch, CURLOPT_HTTPGET, true);
            if (!empty($data)) {
                // Si hay datos en GET, los agregamos a la URL (ej: /transaction/uuid)
                curl_setopt($ch, CURLOPT_URL, $this->baseUrl . $endpoint . '?' . http_build_query($data));
            }
        }

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $curlError = curl_error($ch);
        curl_close($ch);

        if ($curlError) {
            throw new QvaPayException("Error de conexión cURL: " . $curlError);
        }

        $json = json_decode($response, true);

        // Manejo de errores de la API (400, 401, 403, 429, 500)
        if ($httpCode >= 400) {
            $msg = $json['error'] ?? $json['message'] ?? 'Error desconocido en la API de QvaPay.';
            
            // Códigos de error específicos de QvaPay (ej: KYC_REQUIRED)
            if (isset($json['code'])) {
                $msg .= " (Código: " . $json['code'] . ")";
            }
            
            throw new QvaPayException("HTTP {$httpCode}: {$msg}");
        }

        return $json;
    }

    /* ==========================================
     * MÉTODOS PÚBLICOS (API)
     * ========================================== */

    /**
     * Verifica las credenciales de la app y devuelve sus datos.
     */
    public function getInfo() 
    {
        return $this->request('/v2/info');
    }

    /**
     * Consulta el balance actual de la cuenta QvaPay.
     */
    public function getBalance() 
    {
        return $this->request('/v2/balance');
    }

    /**
     * Crea una factura de pago (Para Inversiones).
     * $amount: Monto (ej. 25.00)
     * $description: Descripción visible al usuario
     * $remote_id: Tu ID interno de operación (obligatorio para rastreo)
     * $webhook: URL a donde QvaPay enviará la confirmación
     */
    public function createInvoice($amount, $description, $remote_id, $webhook) 
    {
        return $this->request('/v2/create_invoice', [
            'amount'      => (float) $amount,
            'description' => mb_substr($description, 0, 250),
            'remote_id'   => $remote_id,
            'webhook'     => $webhook
        ]);
    }

    /**
     * Consulta el estado de una transacción específica (Por UUID).
     * Útil para re-verificar los webhooks.
     */
    public function getTransaction($uuid) 
    {
        return $this->request('/transaction/' . urlencode($uuid), [], 'GET');
    }

    /**
     * Envía dinero a otra cuenta QvaPay (Para Retiros).
     * Requiere tener activado "Transferencias internas" en el panel de QvaPay.
     */
    public function transfer($receiverUsername, $amount, $description = '') 
    {
        return $this->request('/transaction/transfer', [
            'receiver'    => ltrim($receiverUsername, '@'),
            'amount'      => (float) $amount,
            'description' => mb_substr($description, 0, 250)
        ]);
    }

    /**
     * Solicita un retiro a una wallet externa o tarjeta (Para Retiros).
     * Requiere tener activado "Retiros a wallets externas" en el panel de QvaPay.
     * $details: Array con los datos del método (ej. ['card_number' => '1234...'])
     */
    public function withdraw($pay_method, $amount, $details) 
    {
        return $this->request('/withdraw', [
            'pay_method' => $pay_method,
            'amount'     => (float) $amount,
            'details'    => $details
        ]);
    }

    /**
     * 🆕 v1.1: Obtiene los promedios de tasas de cambio P2P por moneda.
     * Endpoint público (no requiere autenticación).
     * Devuelve un array asociativo con las monedas como claves.
     * Cada moneda tiene campos: name, average, average_buy, average_sell,
     * count, count_buy, count_sell, median, window_hours, updated_at.
     * 
     * @return array
     */
    public function getP2PAverages()
    {
        return $this->request('/p2p/averages', [], 'GET');
    }
}