(
function() {
    var ol = window.onload;
    var doubleclick = function() {
        var links = document.getElementsByTagName('a');
        for (var i = 0; i < links.length; i++) {
            var link = links[i];
            var href = link.getAttribute('href');
            if (! href) continue;
            if (! href.match(/action=edit/)) continue;
            window.location = href;
            break;
        }
    };
    window.onload = function() {
        if (ol) ol();
        document.body.ondblclick = doubleclick;
    }
}
)();
