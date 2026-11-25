// ═══════════════════════════════════════════════════════════════
// AstroIO Launcher — proxy local (127.0.0.1) con las imágenes del
// juego DENTRO del exe (igual que la APK: no gastan datos).
//
//   1) Imágenes embebidas (assets/game, mismas carpetas que la
//      APK): se sirven desde el propio exe, cero descarga.
//   2) Resto de estáticos (css/js/fuentes/imágenes que falten): se
//      guardan en CACHÉ DE DISCO la primera vez y ya no se piden
//      más al servidor.
//   3) Todo lo dinámico (game.php, ajax) va al servidor por HTTPS,
//      con las cookies adaptadas a 127.0.0.1 para que la sesión
//      funcione igual.
// ═══════════════════════════════════════════════════════════════
package main

import (
	"bytes"
	"crypto/sha1"
	"embed"
	"encoding/hex"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/http/httputil"
	"os"
	"path/filepath"
	"strings"
)

// Imágenes del juego. build.sh las copia de styles/theme/gow antes
// de compilar (las mismas carpetas que lleva la APK dentro).
//
//go:embed assets/game
var gameAssets embed.FS

var mimeByExt = map[string]string{
	".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg",
	".gif": "image/gif", ".webp": "image/webp", ".svg": "image/svg+xml",
	".ico": "image/x-icon", ".css": "text/css", ".js": "application/javascript",
	".woff": "font/woff", ".woff2": "font/woff2", ".ttf": "font/ttf",
	".otf": "font/otf", ".eot": "application/vnd.ms-fontobject",
	".mp3": "audio/mpeg", ".ogg": "audio/ogg", ".wav": "audio/wav",
	".mp4": "video/mp4", ".webm": "video/webm",
}

func isStaticExt(ext string) bool {
	_, ok := mimeByExt[ext]
	return ok
}

type proxyServer struct {
	srv      *http.Server
	port     int
	upstream string
	cacheDir string
	local    string // http://127.0.0.1:PORT
}

// startProxy escucha en 127.0.0.1 (puerto libre) y sirve en background.
func startProxy(cacheDir string) (*proxyServer, error) {
	p := &proxyServer{upstream: serverHost(), cacheDir: cacheDir}
	ln, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		return nil, err
	}
	p.port = ln.Addr().(*net.TCPAddr).Port
	p.local = fmt.Sprintf("http://127.0.0.1:%d", p.port)
	p.srv = &http.Server{Handler: p.handler()}
	go p.srv.Serve(ln)
	fmt.Println("Proxy local listo en", p.local)
	return p, nil
}

func (p *proxyServer) handler() http.Handler {
	rp := &httputil.ReverseProxy{
		Director: func(req *http.Request) {
			req.URL.Scheme = "https"
			req.URL.Host = p.upstream
			req.Host = p.upstream
			// Sin compresión: hay que poder reescribir el HTML
			// (las imágenes van aparte, desde el exe o la caché).
			req.Header.Set("Accept-Encoding", "identity")
			// El servidor debe ver SU dominio (cookies, CSRF, links)
			if req.Header.Get("Origin") != "" {
				req.Header.Set("Origin", "https://"+p.upstream)
			}
			if req.Header.Get("Referer") != "" {
				req.Header.Set("Referer", "https://"+p.upstream+"/")
			}
		},
		ModifyResponse: p.modifyResponse,
		ErrorHandler: func(w http.ResponseWriter, r *http.Request, err error) {
			w.WriteHeader(http.StatusBadGateway)
			io.WriteString(w, "AstroIO: sin conexión con el servidor. Revisa tu Internet y recarga.")
		},
	}
	mux := http.NewServeMux()
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.Method == http.MethodGet && p.serveLocal(w, r) {
			return
		}
		rp.ServeHTTP(w, r)
	})
	return mux
}

// serveLocal intenta servir lo estático de dentro del exe o de la
// caché de disco. Devuelve false si hay que ir al servidor.
func (p *proxyServer) serveLocal(w http.ResponseWriter, r *http.Request) bool {
	ext := strings.ToLower(filepath.Ext(r.URL.Path))
	if !isStaticExt(ext) {
		return false
	}

	// 1) Embebido: las imágenes que lleva el launcher dentro
	if f, err := gameAssets.Open("assets/game" + r.URL.Path); err == nil {
		defer f.Close()
		w.Header().Set("Content-Type", mimeByExt[ext])
		w.Header().Set("Cache-Control", "public, max-age=31536000, immutable")
		io.Copy(w, f)
		return true
	}

	// 2) Caché de disco: descargado una vez, ya no gasta datos
	if data, err := os.ReadFile(p.cacheFile(r)); err == nil {
		w.Header().Set("Content-Type", mimeByExt[ext])
		w.Header().Set("Cache-Control", "public, max-age=86400")
		w.Write(data)
		return true
	}

	return false // no lo tenemos: que lo pida al servidor (y se cachea)
}

// cacheFile nombre de caché estable para una URL estática.
func (p *proxyServer) cacheFile(r *http.Request) string {
	name := strings.ReplaceAll(strings.Trim(r.URL.Path, "/"), "/", "__")
	if r.URL.RawQuery != "" {
		h := sha1.Sum([]byte(r.URL.RawQuery))
		name += "_" + hex.EncodeToString(h[:4])
	}
	return filepath.Join(p.cacheDir, name)
}

func (p *proxyServer) modifyResponse(resp *http.Response) error {
	// Cabeceras que no aplican detrás del proxy local
	resp.Header.Del("Content-Security-Policy")
	resp.Header.Del("Strict-Transport-Security")
	resp.Header.Del("X-Frame-Options")

	// Cookies: convertidas para valer en 127.0.0.1 (la sesión funciona igual)
	if cookies := resp.Header["Set-Cookie"]; len(cookies) > 0 {
		out := make([]string, 0, len(cookies))
		for _, raw := range cookies {
			if c, err := http.ParseSetCookie(raw); err == nil {
				c.Domain = ""
				c.Secure = false
				if c.SameSite == http.SameSiteNoneMode {
					c.SameSite = http.SameSiteLaxMode
				}
				out = append(out, c.String())
			} else {
				out = append(out, raw)
			}
		}
		resp.Header["Set-Cookie"] = out
	}

	// Redirecciones apuntando al dominio real -> al local
	if loc := resp.Header.Get("Location"); strings.Contains(loc, p.upstream) {
		resp.Header.Set("Location", strings.ReplaceAll(loc, "https://"+p.upstream, p.local))
	}

	// Guardar en caché de disco los estáticos que vinieron del servidor
	ext := strings.ToLower(filepath.Ext(resp.Request.URL.Path))
	if resp.StatusCode == 200 && isStaticExt(ext) {
		data, err := io.ReadAll(resp.Body)
		if err == nil {
			resp.Body = io.NopCloser(bytes.NewReader(data))
			_ = os.WriteFile(p.cacheFile(resp.Request), data, 0644)
		}
	}

	// HTML: reescribir dominios absolutos al proxy local
	ct := resp.Header.Get("Content-Type")
	if resp.StatusCode == 200 && strings.Contains(ct, "text/html") {
		data, err := io.ReadAll(resp.Body)
		if err == nil {
			resp.Body.Close()
			hostLocal := strings.TrimPrefix(p.local, "http://")
			s := string(data)
			s = strings.ReplaceAll(s, "https://"+p.upstream, p.local)
			s = strings.ReplaceAll(s, "//"+p.upstream, "//"+hostLocal)
			s = strings.ReplaceAll(s, p.upstream, hostLocal)
			data = []byte(s)
			resp.Body = io.NopCloser(bytes.NewReader(data))
			resp.ContentLength = int64(len(data))
			resp.Header.Set("Content-Length", fmt.Sprintf("%d", len(data)))
		}
	}
	return nil
}
