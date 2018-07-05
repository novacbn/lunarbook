(function (window, document, IntersectionObserver) {
    let FIRST_INTERSECTION      = true;
    let INTERSECTION_OBSERVER   = new IntersectionObserver(onIntersection, {
        rootMargin: "100%"
    });

    let WINDOW_MESSAGES = {
        onHashChange (event, message) {
            let element = document.querySelector(message.hash);
            if (element) element.scrollIntoView();
        }
    }

    function onDOMContentLoaded(event) {
        for (element of document.querySelectorAll("h4")) INTERSECTION_OBSERVER.observe(element);
    }

    function onIntersection(entries, observer) {
        let entry = entries.reduce(function (current, entry) {
            if (current) {
                if (current.isIntersecting && current.intersectionRatio < entry.intersectionRatio) current = entry;
            } else if (entry.isIntersecting) current = entry;

            return current;
        }, null);

        let element = entry ? entry.target : null;

        if (element) {
            if (FIRST_INTERSECTION) {
                FIRST_INTERSECTION = false;
                return;
            }

            window.top.postMessage({
                hash:       "#" + element.getAttribute("id"),
                pathname:   window.top.location.pathname,
                type:       "onFragmentChange"
            }, "*");
        }
    }

    function onMessage(event) {
        let handler = WINDOW_MESSAGES[event.data.type];
        if (handler) handler(event, event.data);
    }

    window.addEventListener("DOMContentLoaded", onDOMContentLoaded);
    window.addEventListener("message", onMessage);
})(window, document, window.IntersectionObserver);
