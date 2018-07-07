window.lunarbook = (function (window, fetch) {
    let cache       = {};
    let root        = "/lunarbook/";
    let fragments   = root + "assets/fragments/";

    return {
        fetchFragment (name) {
            if (cache[name]) {
                return new Promise((resolve, reject) => {
                    resolve(cache[name]);
                });
            }

            return fetch(`${fragments}${name}/index.html`)
                .then((res) => res.text())
                .then((res) => {
                    cache[name] = res;
                    return res;
                });
        }
    }
})(window, window.fetch);

(function (window, document, history, location, lunarbook, YouAreI) {
    let ELEMENT_CONTAINER   = null;
    let ELEMENT_FRAGMENT    = null;
    let ELEMENT_NAVIGATION  = null;

    async function updateFragment(url) {
        let fragment    = url.path_parts().slice(1).join("/");
        let contents    = await lunarbook.fetchFragment(fragment);

        if (ELEMENT_FRAGMENT) ELEMENT_FRAGMENT.remove();
        ELEMENT_FRAGMENT = parseHTML(contents);
        ELEMENT_CONTAINER.appendChild(ELEMENT_FRAGMENT);

        history.pushState(null, "LunarBook", url.to_string());
        onHashChange(null);
    }

    function parseHTML(contents) {
        let element         = document.createElement("div");
        element.innerHTML   = contents;
        return element.firstChild;
    }

    function onClick(event) {
        event.preventDefault();

        let current = new YouAreI(location.href);
        let url     = new YouAreI(event.target.getAttribute("href"));
        if (current.path_to_string() === url.path_to_string()) {
            if (current.fragment() !== url.fragment()) {
                history.pushState(null, "LunarBook", url.to_string());
                onHashChange();
            }

            return;
        };

        updateFragment(url);
    }

    function onDOMContentLoaded(event) {
        ELEMENT_CONTAINER   = document.querySelector("#container");
        ELEMENT_FRAGMENT    = document.querySelector("#fragment");
        ELEMENT_NAVIGATION  = document.querySelector("#navigation");

        let links = document.querySelectorAll("#navigation  a");
        for (element of links) {
            let link = element.getAttribute("href");
            if (link.startsWith("#")) element.setAttribute("href", location.pathname + link);
            element.addEventListener("click", onClick);
        }
    }

    function onHashChange(event) {
        let element = document.querySelector(location.hash);
        if (element) element.scrollIntoView();
    }

    window.addEventListener("DOMContentLoaded", onDOMContentLoaded);
    //window.addEventListener("hashchange", onHashChange);
})(window, document, history, location, lunarbook, YouAreI);