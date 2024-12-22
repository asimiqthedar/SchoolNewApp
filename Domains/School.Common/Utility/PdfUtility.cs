using HtmlAgilityPack;
using System.Xml;

namespace School.Common.Utility
{
	public class PdfUtility
	{
		public static string GetTemplateSubject(ConfigTemplate appEmail)
		{
			string subject = string.Empty;
			try
			{
				XmlDocument xDoc = new XmlDocument();
				var ConfigPath = $"{System.IO.Path.Combine(Directory.GetCurrentDirectory(), "wwwroot")}/EmailTemplates/mailtemplate.config";
				xDoc.Load(ConfigPath);
				XmlNode oXmlNode = xDoc.SelectSingleNode(".//template[@active='yes' and @id='" + appEmail.ToString() + "']/subject");

				if (oXmlNode != null)
				{
					subject = oXmlNode.InnerText;
				}
			}
			catch (Exception ex)
			{
				//_logger.LogError($"Exception:EmailService:GetTemplateSubject : Message :{JsonConvert.SerializeObject(ex)}");
			}
			return subject;
		}
		public static string GetTemplateBody(ConfigTemplate appEmail)
		{
			string body = string.Empty;
			try
			{
				XmlDocument xDoc = new XmlDocument();
				var ConfigPath = $"{System.IO.Path.Combine(Directory.GetCurrentDirectory(), "wwwroot")}/EmailTemplates/mailtemplate.config";
				xDoc.Load(ConfigPath);
				XmlNode oXmlNode = xDoc.SelectSingleNode(".//template[@active='yes' and @id='" + appEmail.ToString() + "']/body");

				if (oXmlNode != null)
				{
					body = oXmlNode.InnerText;
				}
			}
			catch (Exception ex)
			{
				//_logger.LogError($"Exception:EmailService:GetTemplateBody : Message :{JsonConvert.SerializeObject(ex)}");
			}
			return body;
		}
		public static string ProcessTemplate(string html, Dictionary<string, string> mailData)
		{
			foreach (string key in mailData.Keys)
			{
				html = html.Replace("{{" + key + "}}", mailData[key]);
			}
			return html;
		}
		 

        public byte[] PhantomHtmlStringToBytes(string html)
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
				//throw ex;
				return null;
			}
		}


        public byte[] PhantomHtmlStringToBytesSummary(string html, string type)
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
				if (type == "en")
				{
					psi.Arguments = "printinvsummary.js " + rfile + ".html";
				}
				else
				{
					psi.Arguments = "printinvsummary_ar.js " + rfile + ".html";
				}

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
                //throw ex;
                return null;
            }
        }
        

    }
}
