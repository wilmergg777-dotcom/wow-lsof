Message	= {
	MessID : 0,

	/**
	 * Decrementa 1 del data-unread del tab indicado
	 * y actualiza la clase .has-unread.
	 * ⚡ NUEVO v6.3: reemplaza al viejo MessageCount que apuntaba
	 * a elementos #unread_XXX que ya no existen.
	 */
	decrementarTabUnread: function(catId) {
		var btn = document.getElementById('tab_cat_' + catId);
		if (!btn) return;
		var n = parseInt(btn.getAttribute('data-unread'), 10) || 0;
		if (n <= 0) return;
		n = n - 1;
		btn.setAttribute('data-unread', n);
		if (n > 0) {
			btn.classList.add('has-unread');
		} else {
			btn.classList.remove('has-unread');
		}
	},

	/**
	 * Refresca TODOS los contadores pidiendolos al servidor.
	 * URL: game.php?page=messages&mode=getUnreadCounts
	 */
	refrescarTabsUnread: function() {
		$.ajax({
			url: 'game.php?page=messages&mode=getUnreadCounts',
			dataType: 'json',
			success: function(counts) {
				if (!counts || typeof counts !== 'object') return;
				Object.keys(counts).forEach(function(cat) {
					var btn = document.getElementById('tab_cat_' + cat);
					if (!btn) return;
					var n = parseInt(counts[cat], 10) || 0;
					btn.setAttribute('data-unread', n);
					if (n > 0) {
						btn.classList.add('has-unread');
					} else {
						btn.classList.remove('has-unread');
					}
				});
			}
		});
	},

	/**
	 * Mantengo MessageCount por compatibilidad, pero ahora
	 * delega al nuevo sistema de tabs.
	 */
	MessageCount: function() {
		// No hace nada: los tabs se actualizan con decrementarTabUnread()
		// o con refrescarTabsUnread(). Dejo la funcion vacia por si
		// algun otro script la sigue llamando.
	},

	getMessages: function (MessID, page) {
		if (typeof page === "undefined") {
			page = 1;
		}
		Message.MessID	= MessID;
		Message.MessageCount(MessID);
		
		$('#loading').show();
		
		$.get('game.php?page=messages&mode=view&messcat='+MessID+'&site='+page+'&ajax=1', function(data) {
			$('#loading').hide();
			var $container = $('#message_list');
			if ($container.length) {
				$container.html(data);
			} else {
				$('#messagestable').remove();
				$('#content table:eq(0)').after(data);
			}
			$('#message_content').html(
				'<div class="msg-empty">' +
					'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="width:48px;height:48px;margin-bottom:15px;opacity:0.4;"><path d="M3 7l9 6 9-6M3 7v10a2 2 0 002 2h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2z"/></svg>' +
					'<p>Selecciona un mensaje para leerlo</p>' +
				'</div>'
			);
		});
	},

	openMessage: function(id, subject, from, time) {
		// 🛡️ CORREGIDO: Usamos .text() en lugar de .html() para obtener el HTML "desescapado" desde la plantilla
		var content = $('#msg-content-' + id).text();
		if (!content) content = '';
		
		var $item = $('#msg-content-' + id).closest('.msg-item');
		var wasUnread = $item.hasClass('unread');
		
		$('.msg-item').removeClass('active');
		$item.addClass('active');
		
		// Si estaba sin leer, marcarlo como leído en el servidor y quitar el estilo
		if (wasUnread) {
			$item.removeClass('unread');
			$.get('game.php?page=messages&mode=markread&id=' + id);

			// ⚡ v6.3 NUEVO: actualizar los tabs de categoría
			Message.decrementarTabUnread(Message.MessID);   // El tab específico
			if (Message.MessID != 100 && Message.MessID != 101) {
				Message.decrementarTabUnread(100);          // El tab "Todos"
				Message.decrementarTabUnread(101);          // El tab "No leídos"
			}
		}
		
		var html = 
			'<div class="msg-reader-header">' +
				'<div style="display:flex;justify-content:space-between;align-items:flex-start;gap:10px;">' +
					'<h3>' + subject + '</h3>' +
					'<div style="display:flex;gap:6px;flex-shrink:0;">' +
						'<button class="msg-btn-delete" onclick="Message.deleteMessage(' + id + ')" title="Borrar">🗑️</button>' +
						'<button class="msg-btn-delete" onclick="Message.closeMessage()" title="Cerrar">✕</button>' +
					'</div>' +
				'</div>' +
				'<div class="msg-reader-meta">De: ' + from + ' &middot; ' + time + '</div>' +
			'</div>' +
			'<div class="msg-reader-body">' + content + '</div>';
		
		$('#message_content').html(html);
	},

	closeMessage: function() {
		$('.msg-item').removeClass('active');
		$('#message_content').html(
			'<div class="msg-empty">' +
				'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="width:48px;height:48px;margin-bottom:15px;opacity:0.4;"><path d="M3 7l9 6 9-6M3 7v10a2 2 0 002 2h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2z"/></svg>' +
				'<p>Selecciona un mensaje para leerlo</p>' +
			'</div>'
		);
	},

	deleteMessage: function(id) {
		if (!confirm('¿Borrar este mensaje?')) return;
		var f = $('<form>').attr({method:'POST', action:'game.php?page=messages'});
		f.append('<input type="hidden" name="mode" value="action">');
		f.append('<input type="hidden" name="messcat" value="' + Message.MessID + '">');
		f.append('<input type="hidden" name="actionBottom" value="deletemarked">');
		f.append('<input type="hidden" name="submitBottom" value="1">');
		f.append('<input type="hidden" name="messageID[' + id + ']" value="1">');
		f.appendTo('body').submit();
	},

	deleteAll: function() {
		if (!confirm('¿Borrar TODOS los mensajes de esta categoría?')) return;
		var f = $('<form>').attr({method:'POST', action:'game.php?page=messages'});
		f.append('<input type="hidden" name="mode" value="action">');
		f.append('<input type="hidden" name="messcat" value="' + Message.MessID + '">');
		f.append('<input type="hidden" name="actionBottom" value="deleteall">');
		f.append('<input type="hidden" name="submitBottom" value="1">');
		f.appendTo('body').submit();
	},

	markAllRead: function() {
		if (!confirm('¿Marcar TODOS los mensajes como leídos?')) return;
		
		// Mostramos un indicador de carga si existe
		if ($('#loading').length) $('#loading').show();

		$.get('game.php?page=messages&mode=markallread', function(response) {
			if ($('#loading').length) $('#loading').hide();
			
			// 1. Quitar visualmente el "unread" de todos los mensajes en la lista actual
			//    sin tener que recargarla entera (así no parpadea ni se vacía).
			$('.msg-item').removeClass('unread');
			
			// 2. Refrescamos los contadores de los tabs
			Message.refrescarTabsUnread();
			
			// 3. Si estamos en la pestaña de "No leídos" (101), cambiar a "Todos" (100)
			//    porque si no, la lista va a quedar vacía y parecerá que no cargó.
			if (Message.MessID == 101) {
				Message.getMessages(100, 0);
				// Actualizar visualmente el tab activo
				$('#tab_cat_100').addClass('active');
				$('#tab_cat_101').removeClass('active');
			}
			
			// 4. Limpiamos el panel derecho (cerramos el mensaje si había uno abierto)
			Message.closeMessage();
			
		}).fail(function() {
			if ($('#loading').length) $('#loading').hide();
			alert('Hubo un error al intentar marcar los mensajes como leídos. Revisa la consola o los logs del servidor.');
		});
	},

	sendMessage: function() {
		var to = $('#new_msg_to').val();
		var subject = $('#new_msg_subject').val();
		var body = $('#new_msg_body').val();
		
		if (!to || !subject || !body) {
			alert('Rellena todos los campos');
			return;
		}
		
		// Usamos AJAX (POST) para que las comillas, HTML o códigos no rompan el formulario.
		$.post('game.php?page=messages&mode=send', {
			to: to,
			subject: subject,
			text: body
		}, function(response) {
			alert(response);
			$('#newMsgModal').removeClass('open');
			// Limpiamos los campos
			$('#new_msg_to').val('');
			$('#new_msg_subject').val('');
			$('#new_msg_body').val('');
			// Recargamos la lista para ver el mensaje enviado (si estamos en la pestaña de enviados)
			Message.getMessages(Message.MessID, 1);
		}).fail(function() {
			alert('Error de conexión al enviar el mensaje.');
		});
	},

	stripHTML: function (string) { 
		return string.replace(/<(.|\n)*?>/g, ''); 
	},

	CreateAnswer: function (Answer) {
		var Answer	= Message.stripHTML(Answer);
		if(Answer.substr(0, 3) == "Re:") {
			return 'Re[2]:'+Answer.substr(3);
		} else if(Answer.substr(0, 3) == "Re[") {
			var re = Answer.replace(/Re\[(\d+)\]:.*/, '$1');
			return 'Re['+(parseInt(re)+1)+']:'+Answer.substr(5+parseInt(re.length))
		} else {
			return 'Re:'+Answer
		}
	},
	
	getMessagesIDs: function(Infos) {
		var IDs = [];
		$.each(Infos, function(index, mess) {
			if(mess.value == 'on')
				IDs.push(mess.name.replace(/delmes\[(\d+)\]/g, '$1'));
		});	
		return IDs;
	}
}