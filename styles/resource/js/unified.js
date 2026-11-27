function openUbTab(tabId, tabClass) {
    // 1. Ocultar todos los contenidos de las pestañas
    var contents = document.querySelectorAll('.ub-tab-content');
    for (var i = 0; i < contents.length; i++) {
        contents[i].classList.remove('active');
    }

    // 2. Quitar la clase "active" a todos los botones
    var buttons = document.querySelectorAll('.ub-tab-btn');
    for (var i = 0; i < buttons.length; i++) {
        buttons[i].classList.remove('active');
    }

    // 3. Mostrar el contenido seleccionado
    var targetTab = document.getElementById(tabId);
    if (targetTab) {
        targetTab.classList.add('active');
    }

    // 4. Activar el botón seleccionado
    var targetBtn = document.querySelector('.ub-tab-btn.' + tabClass);
    if (targetBtn) {
        targetBtn.classList.add('active');
    }
}