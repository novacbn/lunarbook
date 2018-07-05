(function (window, document, YouAreI) {
    var ELEMENT_ACTIVE_LINK = null;

    let WINDOW_MESSAGES = {
        onHashChange (event, message) {
            let element = findElement(message.hash, message.pathname);
            if (element) updateElement(element);
        }
    }

    function onClick(event) {
        event.preventDefault();

        if (event.target.getAttribute("data-active")) return;
        updateElement(event.target);

        let href = new YouAreI(event.target.getAttribute("href"));

        window.top.postMessage({
            hash:       "#" + href.fragment(),
            pathname:   href.path_to_string(),
            type:       "onFragmentChange"
        }, "*");
    }

    function onDOMContentLoaded() {
        for (element of document.querySelectorAll("a")) element.addEventListener("click", onClick);
    }

    function findElement(hash, pathname) {
        return document.querySelector(`a[href='${pathname}${hash}']`);
    }

    function updateElement(element) {
        if (ELEMENT_ACTIVE_LINK) ELEMENT_ACTIVE_LINK.removeAttribute("data-active");
        ELEMENT_ACTIVE_LINK = element;
        element.setAttribute("data-active", true);
    }

    function onMessage(event) {
        let handler = WINDOW_MESSAGES[event.data.type];
        if (handler) handler(event, event.data);
    }

    window.addEventListener("DOMContentLoaded", onDOMContentLoaded);
    window.addEventListener("message", onMessage);
})(window, document, window.YouAreI);