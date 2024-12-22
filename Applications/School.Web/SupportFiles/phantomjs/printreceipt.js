var page = new WebPage();
var system = require("system");
page.paperSize = {
    format: "Letter",
    orientation: "portrait",
    footer: {
        height: "0.9cm",
        contents: phantom.callback(function (pageNum, numPages) {
            return "<div style='text-align:center;'><small>Page " + pageNum +
              " of " + numPages + "</small></div>";
        })
    },
    header: {
        height: "5cm",
        contents: phantom.callback(function (pageNum, numPages) {
            var html = system.args[4].replace("{headerMid:", "").replace("}", "");
            if (pageNum == 1) {
                html = system.args[3].replace("{headerTop:", "").replace("}", "") + html;
            }
            return html;
        })
    }
};

// assume the file is local, so we don't handle status errors
page.open(system.args[1], function (status) {
    // export to target (can be PNG, JPG or PDF!)
    page.render(system.args[2]);
    phantom.exit();
});