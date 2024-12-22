//var page = new WebPage();
//var system = require("system");
//var phoneImg =  'data:image/png;base64, iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAGXRFWHRTb2Z0d2FyZQB3d3cuaW5rc2NhcGUub3Jnm+48GgAAAcNJREFUOI2l0jtrVFEUBeBv37kTTdQkIIna+EBBibUoIhYpRDCiRLG1sDWICPZiY2Fp4R+wETNIogiCjYgSLBQRLHw/EImPSTKg4jyORS7JjBYiWd3eZ521zt7rsERER1WZWy1r7NaKLUKvpK9gzUrmZOmFVn7faO/XToHxz+tk5YtSOoquf5j+EnFN/dcZxwY/hUptkMYUNraRaniJJkrolawRViwwktea+c5cNM5KC5drUowa7bsjInX4Xk0l+ewwaRyrhE3y+tlMSiOLqnFJnr1XmTll8mPPQv/61yGlmTGN2j3S5TbZgzkxhSfzdXNC02HhgvrybSrfZkArdgjDunpua5lYHDd+hEr1ETagJaXjIq7ge7HMWazFG2zFAw1jcreR43mu1NirUR6QpRZxE314ipV4Wwg9xHrsUXJC+cdG0bPMSH81c2ig5kj/K8k5DBWzVYskpiU/iQ9FIoST6t37jfRX50sY/3ZAxI225UxjGWawTvJO2Gzx400rl7Y72PslA1mc74hMekw8E+7igzCJuTbCoHpzTLEIUnTTHnvsI5HsKhqn/YmUlkP218F/Yv4FkS5rpaF/cDuRxa2lmoPfSPyQsOFGLKIAAAAASUVORK5CYII='; // Pass the image path as a command-line argument
//var faxImg =  'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAGXRFWHRTb2Z0d2FyZQB3d3cuaW5rc2NhcGUub3Jnm+48GgAAAUtJREFUOI2lk71OAlEQhb9ZLpEC5S8k2llYWWxMbDSxtrBZhTcwEn0GKyqfwURfAQyNibW1CVJY22FigFUoSGAZiw3LLhB046nunZ8zM2fuFcKouxUgzyooHcrZ++lVAsdjZ4Oh9QV6h6JLkwUBqZCaZDgpfAOYwDkQwQCt3BVVmSwlqKqF7VYYSFDYWtnuHyDUuteIlIAEsAe8/JKzDzQBD9GaUO+NCI8SDyMrRnIT5BilBEw1SsapvIPqJRYZdKZdHII0Qnl+wf/eggGU8INqZRPsdrZIms1I5Gj8wVuhje16IasalAbCaZQ2cYPq0ZztGTifa+DBUM6d0fhcZ2zyCO8+rz4htCOhwuusLtuYcRen2Pc1cIp9PHVnwbK2MKxKKjh76uIU+1MNfKRVGQrYvdvln0kPsHuHIH5s0FgYNfcCobCYHOaJfucfYWRiq7GobbIAAAAASUVORK5CYII='; // Pass the image path as a command-line argument
//var schoolImg = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAGXRFWHRTb2Z0d2FyZQB3d3cuaW5rc2NhcGUub3Jnm+48GgAAAdxJREFUOI2dkzFoU1EUhr9z0ZpF++LaOoSiTlXqFFGpaFy6pRkUOmXQwUF3CxIEtbODQ5cMVdChr1s6pAWtOLaiOFTBdKih4JD3GqEkSO/v8NLSkFjFM53/3J///ufcc40/RXkjxfGTpwD42dikmGn1o1lPZSG6inQLLAdaBTPgAlgV02vy6Tf9BUpyjEZPMVsHaogxsM8JS6PAGjACOsOn9ANK5rsFFqJnSGeBD8ntvMU0BICsDoyDloAxzL6QT987YDu+TtiY2u89bMwAMB/nmI9zAISNGcobqU4+RRhfSxyUN1IMBs8xe4xHoPM4DeFdBXSp0+l7nJ/AWx3sIw5DmmY7vmuE0QvMVnA4PB4AhwM4FHs80hUH+k4+mGXXB0htpDa7PvgrzgezoPqR/Tl4KhgPk6HxqPNGh2PACKM5zN51RKxjUf+E0WXHdnwbKQssA1XQD/ADeJZAO6CdJPcDyRlVYBkpSxzfcRQzLcxeIp+lENRoxouIYQpBDWwLbItCUEMM04wXk7q/iJijmGn93yJh60ym73dvYkmOc9ETsK/At55VFqs4O41nhMnBaczULbAXYTSO7CboBqY1MOuIVUGvKKRXDtJ7BfaiomP8aibf+eiJTSas3Y/2G6TZ7mSfABi2AAAAAElFTkSuQmCC'; // Pass the image path as a command-line argument
//page.paperSize = {
//	format: "Letter",
//	orientation: "portrait",
//	footer: {
//		height: "3.7cm",
//		contents: phantom.callback(function (pageNum, numPages) {
//			//return "<div style='text-align:center;'><small>Page " + pageNum + " of " + numPages + "</small></div>";
//			return "<div style='width:100%; text-align:center;'>" +
//				"<table style='width:100%; border-collapse:collapse;'>" +
//				"<tr>" +
//				"<td colspan='3' style='border-bottom:1px solid #ddd; text-align:center;font-size:12px;'>" +
//				"<h3 style='color:#00ADEF;'>If you have any queries please contact Enas Aldajani on 920051888 Ext:110 & ealdajani@alsschools.com</h3>" +
//				"</td>" +
//				"</tr>" +
//				"<tr>" +
//				"<td colspan='3' style='border-bottom:1px solid #ddd; text-align:center;font-size:12px;'>" +
//				"<h3 style='color:#00ADEF;'>Advance Learning Co. Ltd. An Nakheel, Riyadh, PO BOX 221985 Riyadh 11311 Kingdom of Saudi Arabia</h3>" +
//				"<h3>شركة التعليم المتطور المحدودة  حي النخيل الغربي, ص.ب 221985, الرياض  11311, المملكة العربية السعودية</h3>" +
//				"</td>" +
//				"</tr>" +
//				"<tr>" +
//				"<td style='width:33.33%; text-align:left;'>" +
//				"<img src='" + phoneImg + "' alt='Phone' style='width:16px; height:16px;'>" +
//				"<span>Telephone:966 11 2070926</span>" +
//				"</td>" +
//				"<td style='width:33.33%; text-align:center;'>" +
//				"<img src='" + faxImg +"' alt='Fax' style='width:16px; height:16px;'>" +
//				"<span>Fax:966 11 2070927</span>" +
//				"</td>" +
//				"<td style='width:33.33%; text-align:right;'>" +
//				"<img src='" + schoolImg +"' alt='Web' style='width:16px; height:16px; margin-right:5px;'>" +
//				"<span>web:www.alsschools.com</span>" +
//				"</td>" +
//				"</tr>" +
//				"<tr>" +
//				"<td colspan='3' style='text-align:center;'>" +
//				"<small>" +
//				"Page " + pageNum +
//				" of " + numPages +
//				"</small>" +
//				"</td>" +
//				"</tr>" +
//				"</table>" +
//				"</div>";
//		})
//	},
//	header: {
//		height: "0cm",
//		contents: phantom.callback(function (pageNum, numPages) {
//			var html = system.args[4].replace("{headerMid:", "").replace("}", "");
//			if (pageNum == 1) {
//				html = system.args[3].replace("{headerTop:", "").replace("}", "") + html;
//			}
//			return html;
//		})
//	}
//};

//// assume the file is local, so we don't handle status errors
//page.open(system.args[1], function (status) {
//	// export to target (can be PNG, JPG or PDF!)
//	page.render(system.args[2]);
//	phantom.exit();
//});
var page = require('webpage').create();
var system = require('system');

// Base64-encoded images
var phoneImg = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAGXRFWHRTb2Z0d2FyZQB3d3cuaW5rc2NhcGUub3Jnm+48GgAAAcNJREFUOI2l0jtrVFEUBeBv37kTTdQkIIna+EBBibUoIhYpRDCiRLG1sDWICPZiY2Fp4R+wETNIogiCjYgSLBQRLHw/EImPSTKg4jyORS7JjBYiWd3eZ521zt7rsERER1WZWy1r7NaKLUKvpK9gzUrmZOmFVn7faO/XToHxz+tk5YtSOoquf5j+EnFN/dcZxwY/hUptkMYUNraRaniJJkrolawRViwwktea+c5cNM5KC5drUowa7bsjInX4Xk0l+ewwaRyrhE3y+tlMSiOLqnFJnr1XmTll8mPPQv/61yGlmTGN2j3S5TbZgzkxhSfzdXNC02HhgvrybSrfZkArdgjDunpua5lYHDd+hEr1ETagJaXjIq7ge7HMWazFG2zFAw1jcreR43mu1NirUR6QpRZxE314ipV4Wwg9xHrsUXJC+cdG0bPMSH81c2ig5kj/K8k5DBWzVYskpiU/iQ9FIoST6t37jfRX50sY/3ZAxI225UxjGWawTvJO2Gzx400rl7Y72PslA1mc74hMekw8E+7igzCJuTbCoHpzTLEIUnTTHnvsI5HsKhqn/YmUlkP218F/Yv4FkS5rpaF/cDuRxa2lmoPfSPyQsOFGLKIAAAAASUVORK5CYII=';
var faxImg = 'data:image/jpeg;base64,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';
var schoolImg = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAGXRFWHRTb2Z0d2FyZQB3d3cuaW5rc2NhcGUub3Jnm+48GgAAAdxJREFUOI2dkzFoU1EUhr9z0ZpF++LaOoSiTlXqFFGpaFy6pRkUOmXQwUF3CxIEtbODQ5cMVdChr1s6pAWtOLaiOFTBdKih4JD3GqEkSO/v8NLSkFjFM53/3J///ufcc40/RXkjxfGTpwD42dikmGn1o1lPZSG6inQLLAdaBTPgAlgV02vy6Tf9BUpyjEZPMVsHaogxsM8JS6PAGjACOsOn9ANK5rsFFqJnSGeBD8ntvMU0BICsDoyDloAxzL6QT987YDu+TtiY2u89bMwAMB/nmI9zAISNGcobqU4+RRhfSxyUN1IMBs8xe4xHoPM4DeFdBXSp0+l7nJ/AWx3sIw5DmmY7vmuE0QvMVnA4PB4AhwM4FHs80hUH+k4+mGXXB0htpDa7PvgrzgezoPqR/Tl4KhgPk6HxqPNGh2PACKM5zN51RKxjUf+E0WXHdnwbKQssA1XQD/ADeJZAO6CdJPcDyRlVYBkpSxzfcRQzLcxeIp+lENRoxouIYQpBDWwLbItCUEMM04wXk7q/iJijmGn93yJh60ym73dvYkmOc9ETsK/At55VFqs4O41nhMnBaczULbAXYTSO7CboBqY1MOuIVUGvKKRXDtJ7BfaiomP8aibf+eiJTSas3Y/2G6TZ7mSfABi2AAAAAElFTkSuQmCC';

// Configure the page
page.paperSize = {
    format: 'Letter',
    orientation: 'portrait',
    footer: {
        height: '3.5cm',
        contents: phantom.callback(function (pageNum, numPages) {
            // Only render footer if it's the last page
            if (pageNum === numPages) {
                return "<table border='0' cellpadding='0' cellspacing='0' style='width:100%; border-collapse:collapse;'>" +
                    "<tr>" +
                    "<td>" +
                    "<div style='width:100%; text-align:center;'>" +
                    "<table border='0' cellpadding='0' cellspacing='0' style='width:100%; border-collapse:collapse;'>" +
                    "<tr>" +
                    "<td colspan='3' style='border-bottom:1px solid #ddd; text-align:center;font-size:12px;'>" +
                    "<h3 style='color:#00ADEF;'>If you have any queries please contact Enas Aldajani on 920051888 Ext:110 & ealdajani@alsschools.com</h3>" +
                    "</td>" +
                    "</tr>" +
                    "<tr>" +
                    "<td colspan='3' style='text-align:center;font-size:12px;'>" +
                    "<h3 style='color:#00ADEF;'>Advance Learning Co. Ltd. An Nakheel, Riyadh, PO BOX 221985 Riyadh 11311 Kingdom of Saudi Arabia</h3>" +
                    "<h3>شركة التعليم المتطور المحدودة حي النخيل الغربي, ص.ب 221985, الرياض 11311, المملكة العربية السعودية</h3>" +
                    "</td>" +
                    "</tr>" +
                    "<tr>" +
                    "<td style='width:33.33%; text-align:left;' valign='top'>" +
                    "&nbsp;&nbsp;&nbsp;<img src='" + phoneImg + "' alt='Phone' style='width:16px; height:16px;'>" +
                    "<span> 920051888</span>" +
                    "</td>" +
                    "<td style='width:33.33%; text-align:center;' valign='top'>" +
                    "<img src='" + faxImg + "' alt='Fax' style='width:16px; height:16px;'>" +
                    "<span> info@alsschools.com</span>" +
                    "</td>" +
                    "<td style='width:33.33%; text-align:right;' valign='top'>" +
                    "<img src='" + schoolImg + "' alt='Web' style='width:16px; height:16px; margin-right:5px;'>" +
                    "<span>www.alsschools.com</span>&nbsp;&nbsp;&nbsp;" +
                    "</td>" +
                    "</tr>" +
                    "</table>" +
                    "</div>" +
                    "</td>" +
                    "</tr>" +
                    "<tr>" +
                    "<td>" +
                    "<div>" +
                    "<h4><span style='float:right; margin-bottom:2px;'>Page- " + pageNum + " / " + numPages + "</span></h4>" +
                    "</div>" +
                    "</td>" +
                    "</tr>" +
                    "</table>";
            } else {
                // Return empty content for other pages
                return "<h4><span style='float:right'>Page- " + pageNum + " / " + numPages + "</span></h4>";
            }
        })
    },
    header: {
        height: '0cm',
        contents: phantom.callback(function (pageNum, numPages) {
            var html = system.args[4].replace("{headerMid:", "").replace("}", "");
            if (pageNum == 1) {
                html = system.args[3].replace("{headerTop:", "").replace("}", "") + html;
            }
            return html;
        })
    }
};


// Open the page and render it to PDF or image
page.open(system.args[1], function (status) {
    if (status === 'success') {
        page.render(system.args[2]);
    } else {
        console.log('Failed to open the page.');
    }
    phantom.exit();
});
