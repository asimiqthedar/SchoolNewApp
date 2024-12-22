var page = new WebPage();
var system = require("system");
// change the paper size to letter, add some borders
// add a footer callback showing page numbers
page.paperSize = {
    format: "Letter",
    orientation: "portrait",
    //margin: { left: "2cm", right: "2cm", top: "1.5cm", bottom: "1.5cm" },
    footer: {
        height: "0.9cm",
        contents: phantom.callback(function (pageNum, numPages) {
            return "<div style='text-align:center;'><small>Page " + pageNum +
              " of " + numPages + "</small></div>";
        })
    },
    header: {
        height: "1cm",
    }
};

// assume the file is local, so we don't handle status errors
page.open(system.args[1], function (status) {
    // export to target (can be PNG, JPG or PDF!)
    page.render(system.args[2]);
    phantom.exit();
});