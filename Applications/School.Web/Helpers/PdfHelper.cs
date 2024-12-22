using HtmlAgilityPack;
using iText.Html2pdf;
using iText.Kernel.Font;
using iText.Kernel.Pdf;
using iText.Kernel.Pdf.Canvas;
using iText.Layout;
using iText.Layout.Element;
using iText.Layout.Properties;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using ZatcaIntegrationSDK;
using ZatcaIntegrationSDK.GeneralLogic;

namespace School.Web.Helpers
{
	public class PdfHelper
    {
        public byte[] HtmlToInvPdfMemory(string html, string lib)
        {
            byte[] pdfBuffer = null;
            if (lib.ToLower() == "phantom")
                pdfBuffer = RunInvPhantom(html);
            else
            {
                pdfBuffer = RunInviText(html);
                // string basePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "CertificateFolder", "TempInvoice");
                //ConvertHtmlToPdf(html, basePath);
            }
            return pdfBuffer;
        }
        #region Phantom
        //public byte[] RunInvPhantom(string html)
        //{
        //    try
        //    {
        //        var htmlDoc = new HtmlDocument();
        //        htmlDoc.LoadHtml(html);

        //        // Remove header elements from the HTML
        //        string headerTop = htmlDoc.GetElementbyId("headerTop")?.InnerHtml?.Trim() ?? "";
        //        string headerMid = htmlDoc.GetElementbyId("headerMid")?.InnerHtml?.Trim() ?? "";

        //        // Remove header elements from the document
        //        var nodesToRemove = htmlDoc.DocumentNode.SelectNodes("//*[@id='headerTop' or @id='headerMid']");
        //        if (nodesToRemove != null)
        //        {
        //            foreach (var node in nodesToRemove)
        //            {
        //                node.Remove();
        //            }
        //        }

        //        // Get the inner HTML of the body
        //        string htmlBody = htmlDoc.DocumentNode.InnerHtml;

        //        // Write modified HTML to a file
        //        string tempHtmlFilePath = Path.GetTempFileName();
        //        File.WriteAllText(tempHtmlFilePath, htmlBody);

        //        // Configure PhantomJS process
        //        string basefolder = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "SupportFiles", "phantomjs");
        //        string phantomJsExePath = Path.Combine(basefolder, "phantomjs.exe");
        //        string scriptPath = Path.Combine(basefolder, "printinv.js");
        //        string outputPdfFilePath = Path.Combine(basefolder, Path.GetRandomFileName() + ".pdf");

        //        // Execute PhantomJS process
        //        string arguments = $"{scriptPath} {tempHtmlFilePath} {outputPdfFilePath} \"{headerTop}\" \"{headerMid}\"";
        //        var psi = new System.Diagnostics.ProcessStartInfo
        //        {
        //            FileName = phantomJsExePath,
        //            Arguments = arguments,
        //            UseShellExecute = false,
        //            RedirectStandardOutput = true,
        //            CreateNoWindow = true
        //        };

        //        var proc = System.Diagnostics.Process.Start(psi);
        //        proc.WaitForExit();

        //        // Check if the PDF file was created
        //        if (File.Exists(outputPdfFilePath))
        //        {
        //            byte[] pdfBytes = File.ReadAllBytes(outputPdfFilePath);

        //            // Cleanup temporary files
        //            File.Delete(tempHtmlFilePath);
        //            File.Delete(outputPdfFilePath);

        //            return pdfBytes;
        //        }

        //        return null;
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}
        public byte[] RunInvPhantom(string html)
        {
            try
            {
                var htmlDoc = new HtmlDocument();
                htmlDoc.LoadHtml(html);

                //string headerTop = htmlDoc.GetElementbyId("headerTop").InnerHtml.Trim();
                //string headerMid = htmlDoc.GetElementbyId("headerMid").InnerHtml.Trim();
                var nodes = new Queue<HtmlNode>(htmlDoc.DocumentNode.Descendants());
                while (nodes.Count > 0)
                {
                    var node = nodes.Dequeue();
                    if (node.Id != "")
                    {
                        var parentNode = node.ParentNode;
                        if (node.Attributes["id"] != null && (string.Compare(node.Attributes["id"].Value, "headerTop", StringComparison.InvariantCulture) == 0 || string.Compare(node.Attributes["id"].Value, "headerMid", StringComparison.InvariantCulture) == 0))
                            if (null != node.ParentNode)
                                parentNode.RemoveChild(node, false);
                    }
                }
                string htmlBody = htmlDoc.DocumentNode.InnerHtml;

                // Remove header elements from the document
                //var nodesToRemove = htmlDoc.DocumentNode.SelectNodes("//*[@id='headerTop' or @id='headerMid']");
                //if (nodesToRemove != null)
                //{
                //    foreach (var node in nodesToRemove)
                //    {
                //        node.Remove();
                //    }
                //}
                string basefolder = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "SupportFiles", "phantomjs");
                string sExeFileName = Path.Combine(basefolder, "phantomjs.exe");
                System.Diagnostics.Process proc = null;
                System.Diagnostics.ProcessStartInfo psi = new System.Diagnostics.ProcessStartInfo();
                psi.WorkingDirectory = Path.GetDirectoryName(sExeFileName);
                string rfile = Path.GetRandomFileName();
                string rfile_path = Path.Combine(basefolder, rfile + ".html");
                string rfile_output_path = Path.Combine(basefolder, rfile + ".pdf");
                File.WriteAllText(rfile_path, @"<html>
          <head>
              <meta charset=""utf-8"">
              <style>
                  body{
                      font-family:'Arial Unicode MS';
                      }
                @page {
                        margin-top: 10pt;
                      }

              </style>
          </head>
          <body>" + htmlBody + @"
          </body>
          </html>");

                //Dictionary<string, string> headerTopDic = new Dictionary<string, string>();
                //headerTopDic.Add("headerTop", headerTop);
                //string topHeader = JsonConvert.SerializeObject(headerTopDic).Replace("\\r\\n", "");

                //Dictionary<string, string> headerMidDic = new Dictionary<string, string>();
                //headerMidDic.Add("headerMid", headerMid);
                //string midHeader = JsonConvert.SerializeObject(headerMidDic).Replace("\\r\\n", "");

                //psi.Arguments = "printinv.js " + rfile + ".html" + " " + rfile + ".pdf ";
                psi.Arguments = "printinv.js " + rfile + ".html";
                psi.Arguments += " " + rfile + ".pdf";
                //psi.Arguments += " "+ "{headerMid:}";
                //psi.Arguments += " "+ "{headerTop:}";
                //psi.Arguments += " "+ "data:image/png;base64, iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAGXRFWHRTb2Z0d2FyZQB3d3cuaW5rc2NhcGUub3Jnm+48GgAAAcNJREFUOI2l0jtrVFEUBeBv37kTTdQkIIna+EBBibUoIhYpRDCiRLG1sDWICPZiY2Fp4R+wETNIogiCjYgSLBQRLHw/EImPSTKg4jyORS7JjBYiWd3eZ521zt7rsERER1WZWy1r7NaKLUKvpK9gzUrmZOmFVn7faO/XToHxz+tk5YtSOoquf5j+EnFN/dcZxwY/hUptkMYUNraRaniJJkrolawRViwwktea+c5cNM5KC5drUowa7bsjInX4Xk0l+ewwaRyrhE3y+tlMSiOLqnFJnr1XmTll8mPPQv/61yGlmTGN2j3S5TbZgzkxhSfzdXNC02HhgvrybSrfZkArdgjDunpua5lYHDd+hEr1ETagJaXjIq7ge7HMWazFG2zFAw1jcreR43mu1NirUR6QpRZxE314ipV4Wwg9xHrsUXJC+cdG0bPMSH81c2ig5kj/K8k5DBWzVYskpiU/iQ9FIoST6t37jfRX50sY/3ZAxI225UxjGWawTvJO2Gzx400rl7Y72PslA1mc74hMekw8E+7igzCJuTbCoHpzTLEIUnTTHnvsI5HsKhqn/YmUlkP218F/Yv4FkS5rpaF/cDuRxa2lmoPfSPyQsOFGLKIAAAAASUVORK5CYII=";
                //psi.Arguments += " "+ "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAGXRFWHRTb2Z0d2FyZQB3d3cuaW5rc2NhcGUub3Jnm+48GgAAAUtJREFUOI2lk71OAlEQhb9ZLpEC5S8k2llYWWxMbDSxtrBZhTcwEn0GKyqfwURfAQyNibW1CVJY22FigFUoSGAZiw3LLhB046nunZ8zM2fuFcKouxUgzyooHcrZ++lVAsdjZ4Oh9QV6h6JLkwUBqZCaZDgpfAOYwDkQwQCt3BVVmSwlqKqF7VYYSFDYWtnuHyDUuteIlIAEsAe8/JKzDzQBD9GaUO+NCI8SDyMrRnIT5BilBEw1SsapvIPqJRYZdKZdHII0Qnl+wf/eggGU8INqZRPsdrZIms1I5Gj8wVuhje16IasalAbCaZQ2cYPq0ZztGTifa+DBUM6d0fhcZ2zyCO8+rz4htCOhwuusLtuYcRen2Pc1cIp9PHVnwbK2MKxKKjh76uIU+1MNfKRVGQrYvdvln0kPsHuHIH5s0FgYNfcCobCYHOaJfucfYWRiq7GobbIAAAAASUVORK5CYII=";
                //psi.Arguments += " "+ "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAGXRFWHRTb2Z0d2FyZQB3d3cuaW5rc2NhcGUub3Jnm+48GgAAAdxJREFUOI2dkzFoU1EUhr9z0ZpF++LaOoSiTlXqFFGpaFy6pRkUOmXQwUF3CxIEtbODQ5cMVdChr1s6pAWtOLaiOFTBdKih4JD3GqEkSO/v8NLSkFjFM53/3J///ufcc40/RXkjxfGTpwD42dikmGn1o1lPZSG6inQLLAdaBTPgAlgV02vy6Tf9BUpyjEZPMVsHaogxsM8JS6PAGjACOsOn9ANK5rsFFqJnSGeBD8ntvMU0BICsDoyDloAxzL6QT987YDu+TtiY2u89bMwAMB/nmI9zAISNGcobqU4+RRhfSxyUN1IMBs8xe4xHoPM4DeFdBXSp0+l7nJ/AWx3sIw5DmmY7vmuE0QvMVnA4PB4AhwM4FHs80hUH+k4+mGXXB0htpDa7PvgrzgezoPqR/Tl4KhgPk6HxqPNGh2PACKM5zN51RKxjUf+E0WXHdnwbKQssA1XQD/ADeJZAO6CdJPcDyRlVYBkpSxzfcRQzLcxeIp+lENRoxouIYQpBDWwLbItCUEMM04wXk7q/iJijmGn93yJh60ym73dvYkmOc9ETsK/At55VFqs4O41nhMnBaczULbAXYTSO7CboBqY1MOuIVUGvKKRXDtJ7BfaiomP8aibf+eiJTSas3Y/2G6TZ7mSfABi2AAAAAElFTkSuQmCC";
                psi.FileName = sExeFileName;
                proc = System.Diagnostics.Process.Start(psi);
                if (!proc.WaitForExit(10 * 60000))
                    proc.Kill();
                proc.Close();

                if (File.Exists(rfile_path))
                    File.Delete(rfile_path);
                if (File.Exists(rfile_output_path))
                {
                    byte[] f_arr = File.ReadAllBytes(rfile_output_path);
                    File.Delete(rfile_output_path);

                    #region Add watermark in pdf
                    //if (!isInv)
                    //{
                    //    List<string> waterMarks = new List<string>();
                    //    waterMarks.Add(_MailData["Payment"]);
                    //    waterMarks.Add(_MailData["PaidDate"]);
                    //    if (_MailData.ContainsKey("PaymentMode"))
                    //        waterMarks.Add(_MailData["PaymentMode"]);
                    //    f_arr = PDFWatermark.PdfToWaterMarkPdf(f_arr, waterMarks);
                    //}
                    #endregion
                    return f_arr;
                }
                return null;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        //public byte[] RunInvPhantom(string html)
        //{
        //    try
        //    {
        //        var htmlDoc = new HtmlDocument();
        //        htmlDoc.LoadHtml(html);

        //        string headerTop = htmlDoc.GetElementbyId("headerTop").InnerHtml.Trim();
        //        string headerMid = htmlDoc.GetElementbyId("headerMid").InnerHtml.Trim();
        //        var nodes = new Queue<HtmlNode>(htmlDoc.DocumentNode.Descendants());
        //        while (nodes.Count > 0)
        //        {
        //            var node = nodes.Dequeue();
        //            if (node.Id != "")
        //            {
        //                var parentNode = node.ParentNode;
        //                if (node.Attributes["id"] != null && (string.Compare(node.Attributes["id"].Value, "headerTop", StringComparison.InvariantCulture) == 0 || string.Compare(node.Attributes["id"].Value, "headerMid", StringComparison.InvariantCulture) == 0))
        //                    if (null != node.ParentNode)
        //                        parentNode.RemoveChild(node, false);
        //            }
        //        }
        //        string htmlBody = htmlDoc.DocumentNode.InnerHtml;
        //        string basefolder = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "SupportFiles", "phantomjs");
        //        string sExeFileName = Path.Combine(basefolder, "phantomjs.exe");
        //        System.Diagnostics.Process proc = null;
        //        System.Diagnostics.ProcessStartInfo psi = new System.Diagnostics.ProcessStartInfo();
        //        psi.WorkingDirectory = Path.GetDirectoryName(sExeFileName);
        //        string rfile = Path.GetRandomFileName();
        //        string rfile_path = Path.Combine(basefolder, rfile + ".html");
        //        string rfile_output_path = Path.Combine(basefolder, rfile + ".pdf");
        //        File.WriteAllText(rfile_path, @"<html>
        //        <head>
        //            <meta charset=""utf-8"">
        //            <style>
        //                body{
        //                    font-family:'Arial Unicode MS';
        //                    }
        //            </style>
        //        </head>
        //        <body>" + htmlBody + @"
        //        </body>
        //        </html>");

        //        Dictionary<string, string> headerTopDic = new Dictionary<string, string>();
        //        headerTopDic.Add("headerTop", headerTop);
        //        string topHeader = JsonConvert.SerializeObject(headerTopDic).Replace("\\r\\n", "");

        //        Dictionary<string, string> headerMidDic = new Dictionary<string, string>();
        //        headerMidDic.Add("headerMid", headerMid);
        //        string midHeader = JsonConvert.SerializeObject(headerMidDic).Replace("\\r\\n", "");

        //        psi.Arguments = $"printinv.js {rfile}.html{rfile}.pdf {topHeader} {midHeader}";
        //        psi.FileName = sExeFileName;
        //        proc = System.Diagnostics.Process.Start(psi);
        //        if (!proc.WaitForExit(10 * 60000))
        //            proc.Kill();
        //        proc.Close();

        //        if (File.Exists(rfile_path))
        //            File.Delete(rfile_path);
        //        if (File.Exists(rfile_output_path))
        //        {
        //            byte[] f_arr = File.ReadAllBytes(rfile_output_path);
        //            File.Delete(rfile_output_path);
        //            return f_arr;
        //        }
        //        return null;
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}
        #endregion

        #region iText      
        public byte[] RunInviText(string html)
        {
            try
            {
                var htmlDoc = new HtmlDocument();
                htmlDoc.LoadHtml(html);

                string topHeaderHtml = htmlDoc.GetElementbyId("headerTop").InnerHtml.Trim();
                string midHeaderHtml = htmlDoc.GetElementbyId("headerMid").InnerHtml.Trim();
                var nodes = new Queue<HtmlNode>(htmlDoc.DocumentNode.Descendants());
                while (nodes.Count > 0)
                {
                    var node = nodes.Dequeue();
                    if (node.Id != "")
                    {
                        var parentNode = node.ParentNode;
                        if (node.Attributes["id"] != null
                            && (string.Compare(node.Attributes["id"].Value, "headerTop", StringComparison.InvariantCulture) == 0
                                || string.Compare(node.Attributes["id"].Value, "headerMid", StringComparison.InvariantCulture) == 0))
                            if (null != node.ParentNode)
                                parentNode.RemoveChild(node, false);
                    }
                }
                string htmlBody = string.Empty;
                htmlBody = @"<html>
                            <head>
                                <style>
                                    @page {
                                        margin-top: 10pt;
                                    }
                                </style>
                            </head>
                            <body>" + htmlDoc.DocumentNode.InnerHtml + @"</body>
                            </html>";
                string basePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "CertificateFolder", "TempInvoice");
                string invoiceFileName = $"Invoice_{DateTime.Now:yyyyMMddHHmmss}.pdf";
                if (!Directory.Exists(basePath))
                    Directory.CreateDirectory(basePath);
                string filePath = Path.Combine(basePath, $"Invoice_{DateTime.Now:yyyyMMddHHmmss}.pdf");
                string tempFilePath = Path.Combine(basePath, $"Invoice_{DateTime.Now:yyyyMMddHHmmss}_temp.pdf");
                using (PdfDocument pdfDocument = new PdfDocument(new PdfWriter(tempFilePath)))
                {
                    ConverterProperties converterProperties = new ConverterProperties();
                    HtmlConverter.ConvertToPdf(htmlBody, pdfDocument, converterProperties);
                }
                using (PdfDocument pdfDoc = new PdfDocument(new PdfReader(tempFilePath), new PdfWriter(filePath)))
                {
                    Document doc = new Document(pdfDoc);
                    int n = pdfDoc.GetNumberOfPages();

                    for (int i = 1; i <= n; i++)
                    {
                        AddPageHeader(doc, i, topHeaderHtml, midHeaderHtml);
                        AddPageNumber(doc, i, n);
                    }
                    doc.Close();
                }
                //if (File.Exists(tempFilePath))
                //    File.Delete(tempFilePath);
                //return filePath;
                byte[] f_arr = null;
                if (File.Exists(filePath))
                {
                    f_arr = File.ReadAllBytes(filePath);
                    if (File.Exists(tempFilePath))
                        File.Delete(tempFilePath);
                    File.Delete(filePath);
                }
                return f_arr;

            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        //public byte[] RunInviText(string html, string rootPath, Dictionary<string, string> _MailData)
        //{
        //    try
        //    {
        //        var htmlDoc = new HtmlDocument();
        //        htmlDoc.LoadHtml(html);

        //        string topHeaderHtml = htmlDoc.GetElementbyId("headerTop").InnerHtml.Trim();
        //        string midHeaderHtml = htmlDoc.GetElementbyId("headerMid").InnerHtml.Trim();

        //        // Remove header elements from the HTML
        //        var headerTopNode = htmlDoc.GetElementbyId("headerTop");
        //        var headerMidNode = htmlDoc.GetElementbyId("headerMid");
        //        headerTopNode?.Remove();
        //        headerMidNode?.Remove();

        //        // Construct HTML body with remaining content
        //        string htmlBody = $@"
        //    <html>
        //    <head>
        //        <style>
        //            @page {{
        //                margin-top: 145pt;
        //            }}
        //        </style>
        //    </head>
        //    <body>
        //        {htmlDoc.DocumentNode.InnerHtml}
        //    </body>
        //    </html>";

        //        string basePath = Path.Combine("D:\\Exertica", "InvoicePDFs", "InvoicePdf");
        //        if (!Directory.Exists(basePath))
        //            Directory.CreateDirectory(basePath);

        //        string tempFilePath = Path.Combine(basePath, _MailData["InvoiceNo"] + "_temp.pdf");
        //        string filePath = Path.Combine(basePath, _MailData["InvoiceNo"] + ".pdf");

        //        // Convert HTML to PDF
        //        using (PdfDocument pdfDocument = new PdfDocument(new PdfWriter(tempFilePath)))
        //        {
        //            ConverterProperties converterProperties = new ConverterProperties();
        //            HtmlConverter.ConvertToPdf(htmlBody, pdfDocument, converterProperties);
        //        }

        //        // Add headers and page numbers
        //        using (PdfDocument pdfDoc = new PdfDocument(new PdfReader(tempFilePath), new PdfWriter(filePath)))
        //        {
        //            Document doc = new Document(pdfDoc);
        //            int n = pdfDoc.GetNumberOfPages();

        //            for (int i = 1; i <= n; i++)
        //            {
        //                AddPageHeader(doc, i, topHeaderHtml, midHeaderHtml);
        //                AddPageNumber(doc, i, n);
        //            }
        //            doc.Close();
        //        }

        //        // Read PDF content to byte array and delete temporary files
        //        byte[] f_arr = null;
        //        if (File.Exists(filePath))
        //        {
        //            f_arr = File.ReadAllBytes(filePath);
        //            File.Delete(tempFilePath);
        //            File.Delete(filePath);
        //        }
        //        return f_arr;
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}
        //public void ConvertHtmlToPdf(string htmlString, string pdfFilePath)
        //{
        //    if (!Directory.Exists(pdfFilePath))
        //        Directory.CreateDirectory(pdfFilePath);
        //    // Create PDF writer
        //    PdfWriter writer = new PdfWriter(pdfFilePath);

        //    // Create PDF document
        //    PdfDocument pdfDocument = new PdfDocument(writer);

        //    // Set up converter properties
        //    ConverterProperties converterProperties = new ConverterProperties();

        //    // Convert HTML string to PDF
        //    HtmlConverter.ConvertToPdf(htmlString, pdfDocument, converterProperties);

        //    // Close PDF document
        //    pdfDocument.Close();
        //}

        public void AddPageNumber(Document oDoc, Int32 nPage, Int32 nTotalPage)
        {

            PdfDocument pdf = oDoc.GetPdfDocument();
            PdfPage page = oDoc.GetPdfDocument().GetPage(nPage);
            iText.Kernel.Geom.Rectangle pageSize = page.GetPageSize();
            PdfCanvas pdfCanvas = new PdfCanvas(page.GetLastContentStream(), page.GetResources(), pdf);
            Canvas canvas = new Canvas(pdfCanvas, pdf, pageSize);
            PdfFont oPdfFont = PdfFontFactory.CreateRegisteredFont(PdfFontFactory.GetRegisteredFonts().ToList().Where(t => t.Contains("times")).FirstOrDefault());
            canvas.SetFont(oPdfFont);
            canvas.SetFontSize(10f);

            //Write text at position
            Paragraph oParagraph = new Paragraph();
            oParagraph.Add(String.Format("Page {0} of {1}", nPage, nTotalPage));
            canvas.ShowTextAligned(oParagraph, 300, 25, TextAlignment.CENTER);

        }
        public void AddPageHeader(Document oDoc, Int32 nPage, string topHeader, string midHeader)
        {
            PdfDocument pdf = oDoc.GetPdfDocument();
            PdfPage page = oDoc.GetPdfDocument().GetPage(nPage);
            iText.Kernel.Geom.Rectangle pageSize = page.GetPageSize();
            PdfCanvas pdfCanvas = new PdfCanvas(page.GetLastContentStream(), page.GetResources(), pdf);
            Canvas canvas = new Canvas(pdfCanvas, pdf, pageSize);
            Paragraph oParagraph = new Paragraph();
            oParagraph.SetMarginLeft(30f);
            oParagraph.SetMarginRight(30f);
            string firstPageHeader = "<div style='width:700px;'>" + topHeader + midHeader + "</div>";
            string otherPageHeader = "<div style='width:700px;'>" + midHeader + "</div>";
            IElement oIElement;
            if (nPage == 1)
                oIElement = HtmlConverter.ConvertToElements(firstPageHeader).ElementAt(0);
            else
                oIElement = HtmlConverter.ConvertToElements(otherPageHeader).ElementAt(0);
            oParagraph.Add((IBlockElement)oIElement);
            canvas.ShowTextAligned(oParagraph, pageSize.GetWidth() / 2, pageSize.GetWidth() + 100, TextAlignment.CENTER);
        }
        #endregion

        #region A3 logic
        public PDFA3Result ConvertXMLToPDFA3(string xmlPath, string pdfPath, string newPdfName)
        {
            PDFA3Result pdfresult = new PDFA3Result();
            XMLPDF xMLPDF = new XMLPDF();
            pdfresult = xMLPDF.ConvertXMLToPDFA3ByteArray(xmlPath, pdfPath);
            if (pdfresult.IsValid)
            {
                if (pdfresult.PDFA3ContentFile != null && pdfresult.PDFA3ContentFile.Length > 0)
                {
                    try
                    {
                        File.WriteAllBytes(newPdfName, pdfresult.PDFA3ContentFile);
                        //return 0;// success
                    }
                    catch (Exception ex)
                    {
                        //MessageBox.Show(ex.InnerException.ToString());
                        //return -3;// exception
                    }

                }
                else
                {
                    //MessageBox.Show("PDF-A3 Not Generated !");
                    //return -2;// PDF-A3 Not Generated
                }
            }
            //return -1;// invalid pdf

            return pdfresult;
        }
        public PDFA3Result ConvertEncodedXMLToPDFA3ByteArray(string encodedinvoice, string pdfPath, string newPdfName,string tempdir)
        {
            PDFA3Result pdfresult = new PDFA3Result();
            XMLPDF xMLPDF = new XMLPDF();
            pdfresult = xMLPDF.ConvertEncodedXMLToPDFA3ByteArray(encodedinvoice, pdfPath, tempdir);
            if (pdfresult.IsValid)
            {
                if (pdfresult.PDFA3ContentFile != null && pdfresult.PDFA3ContentFile.Length > 0)
                {
                    try
                    {
                        File.WriteAllBytes(newPdfName, pdfresult.PDFA3ContentFile);
                        //return 0;// success
                    }
                    catch (Exception ex)
                    {
                        //MessageBox.Show(ex.InnerException.ToString());
                        //return -3;// exception
                    }

                }
                else
                {
                    //MessageBox.Show("PDF-A3 Not Generated !");
                    //return -2;// PDF-A3 Not Generated
                }
            }
            //return -1;// invalid pdf

            return pdfresult;
        }
        #endregion
    }
}
