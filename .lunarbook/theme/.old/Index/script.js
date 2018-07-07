(function (window, document, location) {
    let ELEMENT_IFRAME_FRAGMENT     = null;
    let ELEMENT_IFRAME_NAVIGATION   = null;

    let WINDOW_MESSAGES = {
        onFragmentChange (event, message) {
            // Check if the message source is from navigation or not
            if (event.source.location.pathname.endsWith("spec.navigation")) {
                // The origin of the message is from navigation, check if the fragment path matches
                if (location.pathname !== message.pathname) {
                    // Nope, update the iframe with the new fragment
                    STRING_LAST_PATH = message.pathname;
                    ELEMENT_IFRAME_FRAGMENT.setAttribute("src", "/lunarbook/assets/fragments" + message.pathname);
    
                } else {
                    // Yep, update the iframe with the new fragment section
                    ELEMENT_IFRAME_FRAGMENT.contentWindow.postMessage({
                        hash:   message.hash,
                        type:   "onHashChange"
                    }, "*");
                }

            } else if (ELEMENT_IFRAME_NAVIGATION) {
                // The origin of the message is not from navigation, update navigation with the new section selection
                ELEMENT_IFRAME_NAVIGATION.contentWindow.postMessage({
                    hash:       message.hash,
                    pathname:   message.pathname,
                    type:       "onHashChange"
                }, "*");
            }

            history.pushState(null, "LunarBook", message.pathname + message.hash);
        }
    };

    function onDOMContentLoaded(event) {
        ELEMENT_IFRAME_FRAGMENT     = document.querySelector("#fragment");
        ELEMENT_IFRAME_NAVIGATION   = document.querySelector("#navigation");

        ELEMENT_IFRAME_FRAGMENT.addEventListener("load", onLoad);
        if (ELEMENT_IFRAME_NAVIGATION) ELEMENT_IFRAME_NAVIGATION.addEventListener("load", onLoad);
    }

    function onLoad(event) {
        event.target.contentWindow.postMessage({
            hash:       location.hash,
            pathname:   location.pathname,
            type:       "onHashChange"
        }, "*");
    }

    function onMessage(event) {
        let handler = WINDOW_MESSAGES[event.data.type];
        if (handler) handler(event, event.data);
    }

    window.addEventListener("DOMContentLoaded", onDOMContentLoaded);
    //window.addEventListener("hashchange", onHashChange);
    window.addEventListener("message", onMessage);
})(window, document, window.location);