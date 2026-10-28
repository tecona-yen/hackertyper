((window) => {
    const {document} = window;
    const {currentScript} = document;

    if (!currentScript) return;

    const attr = (key, def, options = ["true", "false"]) => {
        const v = currentScript.getAttribute("data-" + key);
        if (v == null) return def;
        if (options) {
            return options.find((o) => o == v);
        }
        return v;
    };

    const origin = new URL(currentScript.src).origin;
    const is_auto = attr("auto", "true") === "true";

    function fetchLinks(slugs) {
        try {
            return fetch(`${origin}/get/${slugs.join()}/`);
        } catch (e) {
            return null;
        }
    }

    if (!window.linkora) {
        window.linkora = {};
    }

    function buildLinks() {
        const placeholders = document.querySelectorAll(".linkora");
        let slugs = [];
        placeholders.forEach(element => {
            let slug = element.getAttribute("data-slug");
            if (slug) slugs.push(slug);
        });
        if (slugs.length > 0) {
            fetchLinks(slugs).then(r => r.json()).then(({links}) => {
                placeholders.forEach((element, index) => {
                    let link = links[index].link;
                    if(link){
                        let url = link.url || `${origin}/visit/${link.uuid}`;
                        element.innerHTML = `<a href="${url}" target="_blank" rel="nofollow noopener noreferrer">${link.text}</a>`;
                    }
                });
            })
        }
    }

    if (is_auto) {
        window.addEventListener('load', buildLinks)
    }
})(window);
