using java.util;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml;
using School.Services.Entities;
using School.Models;
using School.Common.Helpers;
using School.Models.ZatcaModels;

namespace School.Web.Helpers
{
	public class EmailManager
	{
		
		public readonly ALSContext _ALSContext;
		public EmailManager(ALSContext ALSContext)
		{
			_ALSContext = ALSContext;

        }
		/// <summary>
		/// Get Email
		/// </summary>
		/// <param name="key"></param>
		/// <param name="requestData"></param>
		/// <param name="isSuccess"></param>
		/// <returns></returns>
		public string GetEmail(string key, long invoiceNo,string rootpath)
		{

			switch (key.ToLower())
			{
				case "invoice_preview":
					try
					{
						string invHtml = CreateInvoicePreview("invoice_pdf_simplifiedinvoice", invoiceNo,rootpath);
						return invHtml;
					}
					catch (Exception ex)
					{
						throw ex;
					}
				case "invoice_pdf":
					try
					{
						string invPath = CreateInvoicePdf(key, invoiceNo,rootpath);
						return invPath;
					}
					catch (Exception ex)
					{
						throw ex;
					}
				case "invoice_pdf_simplifiedinvoice":
					try
					{
						string invPath = CreateInvoicePdf(key, invoiceNo,rootpath);
						return invPath;
					}
					catch (Exception ex)
					{
						throw ex;
					}
				default:
					{
						return null;
					}
			}
		}
      

        /// <summary>
        /// Create Invoice Preview
        /// </summary>
        /// <param name="key"></param>
        /// <param name="requestData"></param>
        /// <returns></returns>
        private string CreateInvoicePreview(string key, long invoiceNo,string rootpath)
		{
			try
			{
				Dictionary<string, string> dicInvoiceData = ProcessInvoice(invoiceNo,rootpath);
				string subject = string.Empty;
				string htmlBody = GetTemplateBody(key, rootpath);
				string html_inv = ProcessTemplate(htmlBody, dicInvoiceData);
				return html_inv;
			}
			catch (Exception ex)
			{
				throw ex;
			}
		}

		/// <summary>
		/// Create Invoice Pdf
		/// </summary>
		/// <param name="key"></param>
		/// <param name="requestData"></param>
		/// <returns></returns>
		private string CreateInvoicePdf(string key, long invoiceNo,string rootpath)
		{
			try
			{
				Dictionary<string, string> dicInvoiceData = ProcessInvoice(invoiceNo,rootpath);
				string subject = string.Empty;
				string htmlBody = GetTemplateBody(key,rootpath);
				string html_inv = ProcessTemplate(htmlBody, dicInvoiceData);
				html_inv = html_inv.Replace("font-family:Open Sans, sans-serif;", "");

				PdfHelper pdfHelper = new PdfHelper();
				//byte[] pdfBuffer = pdfHelper.HtmlToInvPdfMemory(html_inv, "iText");

				byte[] pdfBuffer = pdfHelper.HtmlToInvPdfMemory(html_inv, "phantom");

				string invoicePath = $"{Path.Combine(rootpath, "CertificateFolder", "Invoices")}";
				if (!Directory.Exists(invoicePath))
					Directory.CreateDirectory(invoicePath);
				string fileName = $"Invoice_{DateTime.Now:yyyyMMddHHmmss}.pdf";
				string filePath = Path.Combine(invoicePath, fileName);
				if (pdfBuffer != null)
				{
					using (var stream = File.Create(filePath))
					{
						stream.Write(pdfBuffer, 0, pdfBuffer.Length);
					}
				}

				//byte[] linkBuffer = Encoding.Unicode.GetBytes(filePath);
				return filePath;
			}
			catch (Exception ex)
			{
				throw ex;
			}
		}
        
        private Dictionary<string, string> ProcessInvoice(long invoiceNo,string rootpath)
		{
			Dictionary<string, string> dicInvoiceData = new Dictionary<string, string>();
			try
			{
				var invoiceSummary = _ALSContext.vw_Invoices.AsEnumerable().FirstOrDefault(s => s.InvoiceNo == Convert.ToInt32(invoiceNo));

				var invoiceNoLong = invoiceNo;
				//var parentIDLongValue = string.IsNullOrEmpty(invoiceSummary.ParentID) ? 0 : Convert.ToInt64(invoiceSummary.ParentID);

				var invociesummaryRecord = _ALSContext.InvInvoiceSummaries.Where(s => s.InvoiceNo == invoiceNoLong).FirstOrDefault();
				var invociedetailRecords = _ALSContext.InvInvoiceDetails.Where(s => s.InvoiceNo == invoiceNoLong).ToList();
				var mainParentRecord = invociedetailRecords.FirstOrDefault(s => s.ParentId != null && Convert.ToInt64(s.ParentId.Trim()) > 0);
				long parentId = mainParentRecord == null ? 0 : Convert.ToInt64(mainParentRecord.ParentId);

				var tblParentsFirst = _ALSContext.TblParents.Where(s => parentId == s.ParentId).FirstOrDefault();

				var parentCode = string.Empty;
				var FatherIQAMA = string.Empty;
				var ParentName = string.Empty;
				var FatherMobile = string.Empty;
				var FatherEmail = string.Empty;

				if (tblParentsFirst != null)
				{
					parentCode = tblParentsFirst.ParentCode;
					FatherIQAMA = tblParentsFirst.FatherIqamaNo;
					ParentName = tblParentsFirst.FatherName;
					FatherMobile = tblParentsFirst.FatherMobile;
					FatherEmail = tblParentsFirst.FatherEmail;
				}
				else
				{
					FatherIQAMA = invoiceSummary.FatherIQAMA;
					ParentName = invoiceSummary.ParentName;
					FatherMobile = invoiceSummary.MobileNo;
					FatherEmail = invoiceSummary.EmailID;
				}

				if (string.IsNullOrEmpty(FatherIQAMA))
				{
					var rec = invociedetailRecords.FirstOrDefault(s => !string.IsNullOrEmpty(s.IqamaNumber));
					FatherIQAMA = rec == null ? FatherIQAMA : rec.IqamaNumber;
				}

				if (string.IsNullOrEmpty(ParentName))
				{
					var rec = invociedetailRecords.FirstOrDefault(s => !string.IsNullOrEmpty(s.ParentName));
					ParentName = rec == null ? ParentName : rec.ParentName;
				}

				if (string.IsNullOrEmpty(FatherMobile))
				{
					var rec = invociedetailRecords.FirstOrDefault(s => !string.IsNullOrEmpty(s.FatherMobile));
					FatherMobile = rec == null ? FatherMobile : rec.FatherMobile;
				}

				var ECISLogo4 = GetImageBase64Path("ECIS_LOGO.png",rootpath);
				var IBLogo = GetImageBase64Path("IB_CIS_Logo.png", rootpath);
				var ALSLogo = GetImageBase64Path("alsLogo.png", rootpath);
				var CISLogo = GetImageBase64Path("CISlogo.png", rootpath);
				var MOELogo = GetImageBase64Path("MOE_Logo.png", rootpath);

				dicInvoiceData.Add("ECISLogo4", ECISLogo4);
				dicInvoiceData.Add("IBLogo", IBLogo);
				dicInvoiceData.Add("ALSLogo", ALSLogo);
				dicInvoiceData.Add("CISLogo", CISLogo);
				dicInvoiceData.Add("MOELogo", MOELogo);

				// Invoice Detail
				dicInvoiceData.Add("GPVoucherNo", "");
				//dicInvoiceData.Add("ConsumerName", invoiceSummary.CustomerName);
				dicInvoiceData.Add("ParentID", parentCode);
				dicInvoiceData.Add("FatherName", ParentName);
				dicInvoiceData.Add("FatherID", FatherIQAMA);
				//dicInvoiceData.Add("VATNumber", invoiceSummary.VATNo);
				dicInvoiceData.Add("Address", invoiceSummary.Address);
				dicInvoiceData.Add("PhoneNo", FatherMobile);
				dicInvoiceData.Add("Email", FatherEmail);


				if (invociesummaryRecord.InvoiceRefNo.HasValue)
					dicInvoiceData.Add("InvoiceRefNo", Convert.ToString(invociesummaryRecord.InvoiceRefNo.Value));

				dicInvoiceData.Add("PhoneIcon", "data:image/png;base64, iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAGXRFWHRTb2Z0d2FyZQB3d3cuaW5rc2NhcGUub3Jnm+48GgAAAcNJREFUOI2l0jtrVFEUBeBv37kTTdQkIIna+EBBibUoIhYpRDCiRLG1sDWICPZiY2Fp4R+wETNIogiCjYgSLBQRLHw/EImPSTKg4jyORS7JjBYiWd3eZ521zt7rsERER1WZWy1r7NaKLUKvpK9gzUrmZOmFVn7faO/XToHxz+tk5YtSOoquf5j+EnFN/dcZxwY/hUptkMYUNraRaniJJkrolawRViwwktea+c5cNM5KC5drUowa7bsjInX4Xk0l+ewwaRyrhE3y+tlMSiOLqnFJnr1XmTll8mPPQv/61yGlmTGN2j3S5TbZgzkxhSfzdXNC02HhgvrybSrfZkArdgjDunpua5lYHDd+hEr1ETagJaXjIq7ge7HMWazFG2zFAw1jcreR43mu1NirUR6QpRZxE314ipV4Wwg9xHrsUXJC+cdG0bPMSH81c2ig5kj/K8k5DBWzVYskpiU/iQ9FIoST6t37jfRX50sY/3ZAxI225UxjGWawTvJO2Gzx400rl7Y72PslA1mc74hMekw8E+7igzCJuTbCoHpzTLEIUnTTHnvsI5HsKhqn/YmUlkP218F/Yv4FkS5rpaF/cDuRxa2lmoPfSPyQsOFGLKIAAAAASUVORK5CYII=");
				dicInvoiceData.Add("PrinterIcon", "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAGXRFWHRTb2Z0d2FyZQB3d3cuaW5rc2NhcGUub3Jnm+48GgAAAUtJREFUOI2lk71OAlEQhb9ZLpEC5S8k2llYWWxMbDSxtrBZhTcwEn0GKyqfwURfAQyNibW1CVJY22FigFUoSGAZiw3LLhB046nunZ8zM2fuFcKouxUgzyooHcrZ++lVAsdjZ4Oh9QV6h6JLkwUBqZCaZDgpfAOYwDkQwQCt3BVVmSwlqKqF7VYYSFDYWtnuHyDUuteIlIAEsAe8/JKzDzQBD9GaUO+NCI8SDyMrRnIT5BilBEw1SsapvIPqJRYZdKZdHII0Qnl+wf/eggGU8INqZRPsdrZIms1I5Gj8wVuhje16IasalAbCaZQ2cYPq0ZztGTifa+DBUM6d0fhcZ2zyCO8+rz4htCOhwuusLtuYcRen2Pc1cIp9PHVnwbK2MKxKKjh76uIU+1MNfKRVGQrYvdvln0kPsHuHIH5s0FgYNfcCobCYHOaJfucfYWRiq7GobbIAAAAASUVORK5CYII=");
				dicInvoiceData.Add("WebIcon", "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAGXRFWHRTb2Z0d2FyZQB3d3cuaW5rc2NhcGUub3Jnm+48GgAAAdxJREFUOI2dkzFoU1EUhr9z0ZpF++LaOoSiTlXqFFGpaFy6pRkUOmXQwUF3CxIEtbODQ5cMVdChr1s6pAWtOLaiOFTBdKih4JD3GqEkSO/v8NLSkFjFM53/3J///ufcc40/RXkjxfGTpwD42dikmGn1o1lPZSG6inQLLAdaBTPgAlgV02vy6Tf9BUpyjEZPMVsHaogxsM8JS6PAGjACOsOn9ANK5rsFFqJnSGeBD8ntvMU0BICsDoyDloAxzL6QT987YDu+TtiY2u89bMwAMB/nmI9zAISNGcobqU4+RRhfSxyUN1IMBs8xe4xHoPM4DeFdBXSp0+l7nJ/AWx3sIw5DmmY7vmuE0QvMVnA4PB4AhwM4FHs80hUH+k4+mGXXB0htpDa7PvgrzgezoPqR/Tl4KhgPk6HxqPNGh2PACKM5zN51RKxjUf+E0WXHdnwbKQssA1XQD/ADeJZAO6CdJPcDyRlVYBkpSxzfcRQzLcxeIp+lENRoxouIYQpBDWwLbItCUEMM04wXk7q/iJijmGn93yJh60ym73dvYkmOc9ETsK/At55VFqs4O41nhMnBaczULbAXYTSO7CboBqY1MOuIVUGvKKRXDtJ7BfaiomP8aibf+eiJTSas3Y/2G6TZ7mSfABi2AAAAAElFTkSuQmCC");
				//dicInvoiceData.Add("ArabicKey19", "SIMPLIFIED TAX INVOICE فاتورة ضريبية مبسطة");

				dicInvoiceData.Add("InvoiceNo", " : " + Convert.ToString(invoiceSummary.InvoiceNo));
				dicInvoiceData.Add("InvoiceIssueDate", " : " + (invoiceSummary.InvoiceDate.HasValue ? invoiceSummary.InvoiceDate.Value.ToString("dd/MM/yyyy") : ""));

				if (invociesummaryRecord.InvoiceType.ToLower() == "return")
				{
					dicInvoiceData.Add("InvoiceToTitle", "CREDIT NOTE TO");
				}
				else
				{
					dicInvoiceData.Add("InvoiceToTitle", "INVOICE TO");
				}

				if (invoiceSummary.Status.ToLower() == "saved")
				{
					dicInvoiceData.Add("Title", "Draft");

					dicInvoiceData.Add("InvoiceIssueDateTitle", "Date");
					dicInvoiceData.Add("InvoiceIssueDateArabicTitle", "");

					dicInvoiceData.Add("InvoiceNoTitle", "No");
					dicInvoiceData.Add("InvoiceNoArabicTitle", "");
				}
				else
				{
					if (invociesummaryRecord.InvoiceType.ToLower() == "return")
					{
						dicInvoiceData.Add("Title", "CREDIT NOTE");

						dicInvoiceData.Add("InvoiceNoTitle", "Credit Note No");
						dicInvoiceData.Add("InvoiceNoArabicTitle", "رقم مذكرة الائتمان");

						dicInvoiceData.Add("InvoiceIssueDateTitle", "Credit Note Issue Date");
						dicInvoiceData.Add("InvoiceIssueDateArabicTitle", "تاريخ اصدار الفاتورة");
					}
					else
					{
						dicInvoiceData.Add("Title", "SIMPLIFIED TAX INVOICE");

						dicInvoiceData.Add("InvoiceNoTitle", "Invoice No");

						dicInvoiceData.Add("InvoiceNoArabicTitle", "رقم الفاتورة");

						dicInvoiceData.Add("InvoiceIssueDateTitle", "Invoice Issue Date");
						dicInvoiceData.Add("InvoiceIssueDateArabicTitle", "تاريخ اصدار الفاتورة");
					}
				}

				try
				{
					if (invoiceSummary.Status.ToLower() == "saved" || invoiceSummary.Status.ToLower() == "posted")
					{
                        byte[] imageBytes = File.ReadAllBytes(invoiceSummary.QRCodePath);
                        string base64String = Convert.ToBase64String(imageBytes);
                        string qrImg = $"data:image/png;base64,{base64String}";
                        dicInvoiceData.Add("ImgQRByte", qrImg);
                        
					}
					else
					{
                        var qrImg = GetImageBase64Path("Draft_image.jpg", rootpath);
                        dicInvoiceData.Add("ImgQRByte", qrImg);
                    }
				}
				catch (Exception ex)
				{
				}

				if (invociedetailRecords.Any(s => s.InvoiceType.ToLower().Contains("tuition")))
					dicInvoiceData.Add("ItemDetail", CreateInvoiceTuitionItemDetail(invoiceNo));
				else if (invociedetailRecords.Any(s => s.InvoiceType.ToLower().Contains("entrance")))
					dicInvoiceData.Add("ItemDetail", CreateInvoiceEntranceItemDetail(invoiceNo));
				else if (invociedetailRecords.Any(s => s.InvoiceType.ToLower().Contains("uniform")))
					dicInvoiceData.Add("ItemDetail", CreateInvoiceUniformItemDetail(invoiceNo));

				return dicInvoiceData;
			}
			catch (Exception ex)
			{
				throw ex;
			}
		}

		private string GetImageBase64Path(string fileName,string rootpath)
		{
			try
			{
				string qrPath = $"{Path.Combine(rootpath, "Configurations", "Images")}";
				// Ensure the folder exists, create it if it doesn't
				if (!System.IO.Directory.Exists(qrPath))
					System.IO.Directory.CreateDirectory(qrPath);

				string qrfilePath = Path.Combine(qrPath, fileName);

				byte[] imageBytes = File.ReadAllBytes(qrfilePath);
				string base64String = Convert.ToBase64String(imageBytes);
				string qrImg = $"data:image/png;base64,{base64String}";
				return qrImg;

			}
			catch (Exception ex)
			{
				return null;
			}
		}

		private string ProcessTemplate(string html, Dictionary<string, string> mailData)
		{
			foreach (string key in mailData.Keys)
			{
				html = html.Replace("{{" + key + "}}", mailData[key]);
			}
			return html;
		}

		private string CreateInvoiceUniformItemDetail(long invoiceNo)
		{
			try
			{
				InvInvoiceSummary invoiceMaster = _ALSContext.InvInvoiceSummaries.FirstOrDefault(s => s.InvoiceNo == invoiceNo);
				//var invoiceItemList = _zATCAInvoiceContext.InvoiceDetails.Where(s => s.InvoiceNo == invoiceNo && !s.Description.Contains("uniform ")).ToList();
				//var invoiceItemUniformList = _zATCAInvoiceContext.UniformDetails.Where(s => s.InvoiceNo == invoiceNo).ToList();

				long invoiceNoLong = Convert.ToInt64(invoiceNo);
				var invoiceItemList = _ALSContext.InvInvoiceDetails
					.Where(s => s.InvoiceNo == invoiceNoLong).ToList();

				var parentIds = invoiceItemList.Where(s => s.ParentId != null).Select(s => Convert.ToInt64(s.ParentId)).Distinct().ToList();
				//List<tblParent> tblParents = new List<tblParent>();
				var tblParents = _ALSContext.TblParents.Where(s => parentIds.Contains(s.ParentId))
					.Select(s => new { s.ParentId, s.FatherIqamaNo }).ToList();

				var academicIds = invoiceItemList.Where(s => !string.IsNullOrEmpty(s.AcademicYear)).Select(s => Convert.ToInt64(s.AcademicYear)).Distinct().ToList();
				var academicRecords = _ALSContext.TblSchoolAcademics.Where(s => academicIds.Contains(s.SchoolAcademicId)).ToList();

				StringBuilder strInvoiceItem = new StringBuilder();

				decimal totalTaxableAmount = 0;
				decimal totalDiscount = 0;
				decimal totalTaxAmount = 0;
				decimal totalItemSubtotal = 0;

				// Table start: header
				strInvoiceItem.Append(@"
					<table  cellpadding='4' cellspacing='0' style='width:100%; border: 1px solid #ddd; border-collapse: separate; font-size: 12px;page-break-inside: avoid;'>
						<tr style='background-color: #00b0f0; color: white;'>
							<th width='30%' style='border: 1px solid #FFFFFF; text-align: center;'>Description <br> التفاصيل</th>
							<th width='10%'  style='border: 1px solid #FFFFFF; text-align: center;'>Quantity <br> كمية</th>
							<th width='12%'  style='border: 1px solid #FFFFFF; text-align: center;'>Unit Price <br> سعر الوحدة</th>
							<th width='16%'  style='border: 1px solid #FFFFFF; text-align: center;'>Taxable amount<br>المبلغ الخاضع لضريبة</th>
							<th width='14%'  style='border: 1px solid #FFFFFF; text-align: center;'>Tax Amount<br>مبلغ الضريبة</th>
							<th width='18%'  style='border: 1px solid #FFFFFF; text-align: center;'>Item Subtotal Incl VAT<br>المجموع شامل ضريبة القيمة المضافة</th>
						</tr>");

				// Line Item Table start: tuiton /entarnce fee
				foreach (var item in invoiceItemList)
				{
					var description = "";
					if (item.InvoiceType.ToLower().Contains("uniform"))
					{
						description = item.Description.Trim();
					}
					else
					{
						if (string.IsNullOrEmpty(item.Description))
						{
							description = "Fee Type: " + description + item.InvoiceType.Trim();
						}
						else
						{
							description = "Fee Type: " + description + item.Description.Trim();
						}
						if (!string.IsNullOrEmpty(item.StudentName))
						{
							description = description + "<br/> Student Name: " + item.StudentName.Trim();
						}

						var academicRecord = academicRecords.Where(s => s.SchoolAcademicId.ToString() == item.AcademicYear).FirstOrDefault();
						if (academicRecord != null)
						{
							description = description + "<br/> Academic Year: (" + academicRecord.AcademicYear + ")";
						}

						if (item.GradeId.HasValue)
						{
							var gradeRecord = _ALSContext.TblGradeMasters.Where(s => item.GradeId.Value == s.GradeId).FirstOrDefault();

							if (gradeRecord != null)
							{
								description = description + "<br/> Grade: " + gradeRecord.GradeName.Trim();
							}
						}
					}

					strInvoiceItem.AppendFormat(@"
						<tr style='background-color: #f2f2f2; '>
							<td style='border: 1px solid #FFFFFF;'>{0}</td>
							<td style='border: 1px solid #FFFFFF; text-align: center;'>{1}</td>
							<td style='border: 1px solid #FFFFFF; text-align: right;'>{2}</td>
							<td style='border: 1px solid #FFFFFF; text-align: right;'>{3}</td>
							<td style='border: 1px solid #FFFFFF; text-align: right;'>{4}</td>
							<td style='border: 1px solid #FFFFFF; text-align: right;'>{5}</td>
						</tr>",
						description,
						Convert.ToInt32(item.Quantity),
						item.UnitPrice.ToTwoDecimalString() ?? "0.00",
						item.TaxableAmount?.ToTwoDecimalString() ?? "0.00",
						item.TaxAmount?.ToTwoDecimalString() ?? "0.00",
						item.ItemSubtotal.ToTwoDecimalString() ?? "0.00");

					totalTaxableAmount += item.TaxableAmount ?? 0;
					totalDiscount += item.Discount ?? 0;
					totalTaxAmount += item.TaxAmount ?? 0;
					totalItemSubtotal += item.ItemSubtotal;
				}

				var totalCount = invoiceItemList.Count;// + invoiceItemUniformList.Count;

				for (int i = totalCount; i < 3; i++)
				{
					strInvoiceItem.AppendFormat(@"
						<tr style='background-color: #f2f2f2;'>
							<td style=''></td>
							<td style='text-align: center;'></td>
							<td style='text-align: center;'></td>
							<td style='text-align: center;'></td>
							<td style='text-align: center;'></td>
							<td style='text-align: center;'></td>
						</tr>"
						);
				}

				// Summary rows
				strInvoiceItem.AppendFormat(@"
						<tr>  
							<td colspan='3' style='text-align: left;'>Total (Excluding VAT)</td>
							<td colspan='2' style='text-align: right; border-right: 1px solid #f2f2f2;'>
								اجمالي غير شامل ضربية القيمة المضافة
							</td>
							<td style='text-align: right;'>{0}</td>
						</tr>
						<tr>
							<td colspan='3' style='text-align: left;'>Discount</td>
							<td colspan='2' style='text-align: right; border-right: 1px solid #f2f2f2;'>
								مجموع الخصومات
							</td>
							<td style='text-align: right;'>{1}</td>
						</tr>
						<tr>
							<td colspan='3' style='text-align: left;'>Total Taxable Amount (Excluding VAT)</td>
							<td colspan='2' style='text-align: right; border-right: 1px solid #f2f2f2;'>
								اجمالي الخاضع للضريبة غير شامل ضربية القيمة المضافة
							</td>
							<td style='text-align: right;'>{2}</td>
						</tr>
						<tr>
							<td colspan='3' style='text-align: left;'>Total VAT</td>
							<td colspan='2' style='text-align: right;border-right: 1px solid #f2f2f2;'>
								مجموع ضربية القيمة المضافة 
							</td>
							<td style='text-align: right;'>{3}</td>
						</tr>
						<tr style='font-weight: bold; background-color: #f2f2f2;'>
							<td colspan='3' style='text-align: left; font-size:14px;'>Total Amount Due</td>
							<td colspan='2' style='text-align: right; font-size:14px;'> اجمالي المبلغ المستحق</td>
							<td style='text-align: right; font-size:14px;'>{4}</td>
						</tr>
					</table>",
					totalTaxableAmount.ToTwoDecimalString(),
					totalDiscount.ToTwoDecimalString(),
					(totalTaxableAmount - totalDiscount).ToTwoDecimalString(),
					totalTaxAmount.ToTwoDecimalString(),
					totalItemSubtotal.ToTwoDecimalString());

				//Payment Table
				AddPaymentInfo(strInvoiceItem, invoiceMaster, totalTaxableAmount, totalDiscount, totalTaxAmount, totalItemSubtotal);

				return strInvoiceItem.ToString();
			}
			catch (Exception ex)
			{
				throw ex;
			}
		}

		private string CreateInvoiceTuitionItemDetail(long invoiceNo)
		{
			try
			{
				InvInvoiceSummary invoiceMaster = _ALSContext.InvInvoiceSummaries.FirstOrDefault(s => s.InvoiceNo == invoiceNo);
				long invoiceNoLong = Convert.ToInt64(invoiceNo);
				var invoiceItemList = _ALSContext.InvInvoiceDetails
					.Where(s => s.InvoiceNo == invoiceNoLong).ToList();

				var parentIds = invoiceItemList.Where(s => s.ParentId != null).Select(s => Convert.ToInt64(s.ParentId)).Distinct().ToList();
				var tblParents = _ALSContext.TblParents.Where(s => parentIds.Contains(s.ParentId))
					.Select(s => new { s.ParentId, s.FatherIqamaNo }).ToList();

				var academicIds = invoiceItemList.Where(s => !string.IsNullOrEmpty(s.AcademicYear)).Select(s => Convert.ToInt64(s.AcademicYear)).Distinct().ToList();
				var academicRecords = _ALSContext.TblSchoolAcademics.Where(s => academicIds.Contains(s.SchoolAcademicId)).ToList();

				StringBuilder strInvoiceItem = new StringBuilder();

				decimal totalTaxableAmount = 0;
				decimal totalDiscount = 0;
				decimal totalTaxAmount = 0;
				decimal totalItemSubtotal = 0;

				// Table start: header
				strInvoiceItem.Append(@"
                <table  cellpadding='4' cellspacing='0' style='width:100%; border: 1px solid #ddd; border-collapse: separate; font-size: 12px;page-break-inside: avoid;'>
                    <tr style='background-color: #00b0f0; color: white;'>
                        <th width='30%' style='border: 1px solid #FFFFFF; text-align: center;'>Description <br> التفاصيل</th>
                        <th width='10%'  style='border: 1px solid #FFFFFF; text-align: center;'>Academic Year <br> السنة الأكاديمية</th>
                        <th width='12%'  style='border: 1px solid #FFFFFF; text-align: center;'>Grade <br> الصف</th>
                        <th width='16%'  style='border: 1px solid #FFFFFF; text-align: center;'>Taxable amount<br>المبلغ الخاضع لضريبة</th>
                        <th width='14%'  style='border: 1px solid #FFFFFF; text-align: center;'>Tax Amount<br>مبلغ الضريبة</th>
                        <th width='18%'  style='border: 1px solid #FFFFFF; text-align: center;'>Item Subtotal Incl VAT<br>المجموع شامل ضريبة القيمة المضافة</th>
                    </tr>");

				// Line Item Table start: tuition/entrance fee
				foreach (var item in invoiceItemList)
				{
					var description = "";
					string academicYear = "";
					string gradeName = "";

					if (item.InvoiceType.ToLower().Contains("uniform"))
					{
						description = item.Description.Trim();
					}
					else
					{
						if (item.IsAdvance.HasValue && item.IsAdvance.Value)
						{
							description = "Fee Type: Advance Payment";
						}
						else
						{
							if (string.IsNullOrEmpty(item.Description))
							{
								description = "Fee Type: " + description + item.InvoiceType.Trim();
							}
							else
							{
								description = "Fee Type: " + description + item.Description.Trim();
							}
						}
						if (!string.IsNullOrEmpty(item.StudentName))
						{
							description = description + "<br/> Student Name: " + item.StudentName.Trim();
						}

						// Fetch academic year and grade information
						var academicRecordTemp = academicRecords.Where(s => s.SchoolAcademicId.ToString() == item.AcademicYear).FirstOrDefault();
						if (academicRecordTemp != null)
						{
							academicYear = academicRecordTemp.AcademicYear ?? "N/A";
						}

						if (item.GradeId.HasValue)
						{
							var gradeRecord = _ALSContext.TblGradeMasters.Where(s => item.GradeId.Value == s.GradeId).FirstOrDefault();

							if (gradeRecord != null)
							{
								gradeName = gradeRecord.GradeName.Trim();
							}
						}
					}

					// Now use the variables within the AppendFormat method
					strInvoiceItem.AppendFormat(@"
							<tr style='background-color: #f2f2f2;'>
								<td style='border: 1px solid #FFFFFF;'>{0}</td>
								<td style='border: 1px solid #FFFFFF; text-align: center;'>{1}</td>
								<td style='border: 1px solid #FFFFFF; text-align: center;'>{2}</td>
								<td style='border: 1px solid #FFFFFF; text-align: right;'>{3}</td>
								<td style='border: 1px solid #FFFFFF; text-align: right;'>{4}</td>
								<td style='border: 1px solid #FFFFFF; text-align: right;'>{5}</td>
							</tr>",
					description,
					academicYear,
					gradeName,
					item.TaxableAmount?.ToTwoDecimalString() ?? "0.00",
					item.TaxAmount?.ToTwoDecimalString() ?? "0.00",
					item.ItemSubtotal.ToTwoDecimalString() ?? "0.00"
				);

					totalTaxableAmount += item.TaxableAmount ?? 0;
					totalDiscount += item.Discount ?? 0;
					totalTaxAmount += item.TaxAmount ?? 0;
					totalItemSubtotal += item.ItemSubtotal;
				}

				var totalCount = invoiceItemList.Count;

				for (int i = totalCount; i < 3; i++)
				{
					strInvoiceItem.AppendFormat(@"
                    <tr style='background-color: #f2f2f2;'>
                        <td style=''></td>
                        <td style='text-align: center;'></td>
                        <td style='text-align: center;'></td>
                        <td style='text-align: center;'></td>
                        <td style='text-align: center;'></td>
                        <td style='text-align: center;'></td>
                    </tr>"
					);
				}

				// Summary rows
				strInvoiceItem.AppendFormat(@"
                        <tr>  
                            <td colspan='3' style='text-align: left;'>Total (Excluding VAT)</td>
                            <td colspan='2' style='text-align: right; border-right: 1px solid #f2f2f2;'>اجمالي غير شامل ضربية القيمة المضافة</td>
                            <td style='text-align: right;'>{0}</td>
                        </tr>
                        <tr>
                            <td colspan='3' style='text-align: left;'>Discount</td>
                            <td colspan='2' style='text-align: right; border-right: 1px solid #f2f2f2;'>مجموع الخصومات</td>
                            <td style='text-align: right;'>{1}</td>
                        </tr>
                        <tr>
                            <td colspan='3' style='text-align: left;'>Total Taxable Amount (Excluding VAT)</td>
                            <td colspan='2' style='text-align: right; border-right: 1px solid #f2f2f2;'>اجمالي الخاضع للضريبة غير شامل ضربية القيمة المضافة</td>
                            <td style='text-align: right;'>{2}</td>
                        </tr>
                        <tr>
                            <td colspan='3' style='text-align: left;'>Total VAT</td>
                            <td colspan='2' style='text-align: right;border-right: 1px solid #f2f2f2;'>مجموع ضربية القيمة المضافة </td>
                            <td style='text-align: right;'>{3}</td>
                        </tr>
                        <tr style='font-weight: bold; background-color: #f2f2f2;'>
                            <td colspan='3' style='text-align: left; font-size:14px;'>Total Amount Due</td>
                            <td colspan='2' style='text-align: right; font-size:14px;'> اجمالي المبلغ المستحق</td>
                            <td style='text-align: right; font-size:14px;'>{4}</td>
                        </tr>
                    </table>",
					totalTaxableAmount.ToTwoDecimalString(),
					totalDiscount.ToTwoDecimalString(),
					(totalTaxableAmount - totalDiscount).ToTwoDecimalString(),
					totalTaxAmount.ToTwoDecimalString(),
					totalItemSubtotal.ToTwoDecimalString());

				// Payment Table
				AddPaymentInfo(strInvoiceItem, invoiceMaster, totalTaxableAmount, totalDiscount, totalTaxAmount, totalItemSubtotal);

				return strInvoiceItem.ToString();
			}
			catch (Exception ex)
			{
				throw ex;
			}
		}
		private string CreateInvoiceEntranceItemDetail(long invoiceNo)
		{
			try
			{
				InvInvoiceSummary invoiceMaster = _ALSContext.InvInvoiceSummaries.FirstOrDefault(s => s.InvoiceNo == invoiceNo);
				//var invoiceItemList = _zATCAInvoiceContext.InvoiceDetails.Where(s => s.InvoiceNo == invoiceNo && !s.Description.Contains("uniform ")).ToList();
				//var invoiceItemUniformList = _zATCAInvoiceContext.UniformDetails.Where(s => s.InvoiceNo == invoiceNo).ToList();

				long invoiceNoLong = Convert.ToInt64(invoiceNo);
				var invoiceItemList = _ALSContext.InvInvoiceDetails
					.Where(s => s.InvoiceNo == invoiceNoLong).ToList();

				var parentIds = invoiceItemList.Where(s => s.ParentId != null).Select(s => Convert.ToInt64(s.ParentId)).Distinct().ToList();
				//List<tblParent> tblParents = new List<tblParent>();
				var tblParents = _ALSContext.TblParents.Where(s => parentIds.Contains(s.ParentId))
					.Select(s => new { s.ParentId, s.FatherIqamaNo }).ToList();

				var academicIds = invoiceItemList.Where(s => !string.IsNullOrEmpty(s.AcademicYear)).Select(s => Convert.ToInt64(s.AcademicYear)).Distinct().ToList();
				var academicRecords = _ALSContext.TblSchoolAcademics.Where(s => academicIds.Contains(s.SchoolAcademicId)).ToList();

				StringBuilder strInvoiceItem = new StringBuilder();

				decimal totalTaxableAmount = 0;
				decimal totalDiscount = 0;
				decimal totalTaxAmount = 0;
				decimal totalItemSubtotal = 0;

				// Table start: header
				strInvoiceItem.Append(@"
					<table  cellpadding='4' cellspacing='0' style='width:100%; border: 1px solid #ddd; border-collapse: separate; font-size: 12px;page-break-inside: avoid;'>
						<tr style='background-color: #00b0f0; color: white;'>
							<th width='30%' style='border: 1px solid #FFFFFF; text-align: center;'>Description <br> التفاصيل</th>
							<th width='10%'  style='border: 1px solid #FFFFFF; text-align: center;'>Quantity <br> كمية</th>
							<th width='12%'  style='border: 1px solid #FFFFFF; text-align: center;'>Unit Price <br> سعر الوحدة</th>
							<th width='16%'  style='border: 1px solid #FFFFFF; text-align: center;'>Taxable amount<br>المبلغ الخاضع لضريبة</th>
							<th width='14%'  style='border: 1px solid #FFFFFF; text-align: center;'>Tax Amount<br>مبلغ الضريبة</th>
							<th width='18%'  style='border: 1px solid #FFFFFF; text-align: center;'>Item Subtotal Incl VAT<br>المجموع شامل ضريبة القيمة المضافة</th>
						</tr>");

				// Line Item Table start: tuiton /entarnce fee
				foreach (var item in invoiceItemList)
				{
					var description = "";
					if (item.InvoiceType.ToLower().Contains("uniform"))
					{
						description = item.Description.Trim();
					}
					else
					{
						if (string.IsNullOrEmpty(item.Description))
						{
							description = "Fee Type: " + description + item.InvoiceType.Trim();
						}
						else
						{
							description = "Fee Type: " + description + item.Description.Trim();
						}
						if (!string.IsNullOrEmpty(item.StudentName))
						{
							description = description + "<br/> Student Name: " + item.StudentName.Trim();
						}

						var academicRecord = academicRecords.Where(s => s.SchoolAcademicId.ToString() == item.AcademicYear).FirstOrDefault();
						if (academicRecord != null)
						{
							description = description + "<br/> Academic Year: (" + academicRecord.AcademicYear + ")";
						}

						if (item.GradeId.HasValue)
						{
							var gradeRecord = _ALSContext.TblGradeMasters.Where(s => item.GradeId.Value == s.GradeId).FirstOrDefault();

							if (gradeRecord != null)
							{
								description = description + "<br/> Grade: " + gradeRecord.GradeName.Trim();
							}
						}
					}

					strInvoiceItem.AppendFormat(@"
						<tr style='background-color: #f2f2f2; '>
							<td style='border: 1px solid #FFFFFF;'>{0}</td>
							<td style='border: 1px solid #FFFFFF; text-align: center;'>{1}</td>
							<td style='border: 1px solid #FFFFFF; text-align: right;'>{2}</td>
							<td style='border: 1px solid #FFFFFF; text-align: right;'>{3}</td>
							<td style='border: 1px solid #FFFFFF; text-align: right;'>{4}</td>
							<td style='border: 1px solid #FFFFFF; text-align: right;'>{5}</td>
						</tr>",
						description,
						Convert.ToInt32(item.Quantity),
						item.UnitPrice.ToTwoDecimalString() ?? "0.00",
						item.TaxableAmount?.ToTwoDecimalString() ?? "0.00",
						item.TaxAmount?.ToTwoDecimalString() ?? "0.00",
						item.ItemSubtotal.ToTwoDecimalString() ?? "0.00");

					totalTaxableAmount += item.TaxableAmount ?? 0;
					totalDiscount += item.Discount ?? 0;
					totalTaxAmount += item.TaxAmount ?? 0;
					totalItemSubtotal += item.ItemSubtotal;
				}

				var totalCount = invoiceItemList.Count;// + invoiceItemUniformList.Count;

				for (int i = totalCount; i < 3; i++)
				{
					strInvoiceItem.AppendFormat(@"
						<tr style='background-color: #f2f2f2;'>
							<td style=''></td>
							<td style='text-align: center;'></td>
							<td style='text-align: center;'></td>
							<td style='text-align: center;'></td>
							<td style='text-align: center;'></td>
							<td style='text-align: center;'></td>
						</tr>"
						);
				}

				// Summary rows
				strInvoiceItem.AppendFormat(@"
						<tr>  
							<td colspan='3' style='text-align: left;'>Total (Excluding VAT)</td>
							<td colspan='2' style='text-align: right; border-right: 1px solid #f2f2f2;'>
								اجمالي غير شامل ضربية القيمة المضافة
							</td>
							<td style='text-align: right;'>{0}</td>
						</tr>
						<tr>
							<td colspan='3' style='text-align: left;'>Discount</td>
							<td colspan='2' style='text-align: right; border-right: 1px solid #f2f2f2;'>
								مجموع الخصومات
							</td>
							<td style='text-align: right;'>{1}</td>
						</tr>
						<tr>
							<td colspan='3' style='text-align: left;'>Total Taxable Amount (Excluding VAT)</td>
							<td colspan='2' style='text-align: right; border-right: 1px solid #f2f2f2;'>
								اجمالي الخاضع للضريبة غير شامل ضربية القيمة المضافة
							</td>
							<td style='text-align: right;'>{2}</td>
						</tr>
						<tr>
							<td colspan='3' style='text-align: left;'>Total VAT</td>
							<td colspan='2' style='text-align: right;border-right: 1px solid #f2f2f2;'>
								مجموع ضربية القيمة المضافة 
							</td>
							<td style='text-align: right;'>{3}</td>
						</tr>
						<tr style='font-weight: bold; background-color: #f2f2f2;'>
							<td colspan='3' style='text-align: left; font-size:14px;'>Total Amount Due</td>
							<td colspan='2' style='text-align: right; font-size:14px;'> اجمالي المبلغ المستحق</td>
							<td style='text-align: right; font-size:14px;'>{4}</td>
						</tr>
					</table>",
					totalTaxableAmount.ToTwoDecimalString(),
					totalDiscount.ToTwoDecimalString(),
					(totalTaxableAmount - totalDiscount).ToTwoDecimalString(),
					totalTaxAmount.ToTwoDecimalString(),
					totalItemSubtotal.ToTwoDecimalString());

				//Payment Table
				AddPaymentInfo(strInvoiceItem, invoiceMaster, totalTaxableAmount, totalDiscount, totalTaxAmount, totalItemSubtotal);

				return strInvoiceItem.ToString();
			}
			catch (Exception ex)
			{
				throw ex;
			}
		}

		private void AddPaymentInfo(StringBuilder strInvoiceItem, InvInvoiceSummary invoiceMaster,
	decimal totalTaxableAmount = 0, decimal totalDiscount = 0, decimal totalTaxAmount = 0, decimal totalItemSubtotal = 0)
		{
			strInvoiceItem.Append(@"
                <table  cellpadding='4' cellspacing='0' style='border-collapse:collapse; font-size:10px;float:left;width:100%;page-break-inside: avoid;'>
                    <tr>
                        <td style='text-align:left;float:left;vertical-align: top; width:45%'>");

			AddPaymentMethodInfo(strInvoiceItem, invoiceMaster);

			strInvoiceItem.Append(@"</td>
				        <td></td>
                        <td style='text-align:left; vertical-align: top; float:right;width:55%'>");

			AddBankDetail(strInvoiceItem);

			strInvoiceItem.Append(@"</td>
                    </tr>
                </table>
            ");

			//AddQueryLine(strInvoiceItem);
		}

		private void AddPaymentMethodInfo(StringBuilder strInvoiceItem, InvInvoiceSummary invoiceMaster)
		{
			var invoiceNo = Convert.ToInt64(invoiceMaster.InvoiceNo);
		
			var paymentMethodList = (from
									 payInvoice in _ALSContext.InvInvoicePayments.AsQueryable()

									 join pay in _ALSContext.TblPaymentMethods.AsQueryable()
									 on payInvoice.PaymentMethodId equals pay.PaymentMethodId

									 join payCat in _ALSContext.TblPaymentMethodCategories.AsQueryable()
									 on pay.PaymentMethodCategoryId equals payCat.PaymentMethodCategoryId

									 where payInvoice.InvoiceNo== invoiceNo

									 select new InvoicePaymentEmailInfo
									 {
										 PaymentMethodCategoryId = pay.PaymentMethodCategoryId,
										 PaymentMethodId = pay.PaymentMethodId,
										 PaymentMethodName = pay.PaymentMethodName,
										 PaymentReferenceNumber = payInvoice.PaymentReferenceNumber,
										 CategoryName = payCat.CategoryName,
										 PaymentAmount = payInvoice.PaymentAmount
									 })
									.ToList();


			strInvoiceItem.Append(@"
				<table cellpadding='4' cellspacing='0' style='border-collapse:collapse; text-align:left;float:left;width:65%;font-size:10px;'>
				<tr>
					<th colspan='2' style='text-align:left;font-weight:bold;background-color:white;padding-bottom:10px;'>PAYMENT METHOD</th>
				</tr>
				<tr style='background-color: #00b0f0;color:#FFF;'>
					<td style='font-weight: bold;'>Type</td>           
					<td style='font-weight: bold;'>No</td>
					<td style='font-weight: bold;'>Amount</td>
				</tr>");

			// Cash row
			AddCashRow(strInvoiceItem, paymentMethodList);

			// Wire Transfer row
			AddWireTransferRow(strInvoiceItem, paymentMethodList);

			// Cheque No row
			AddChequeNoRow(strInvoiceItem, paymentMethodList);

			// Card row
			AddCardRow(strInvoiceItem, paymentMethodList);

			strInvoiceItem.Append("</table>");
		}

		private void AddCardRow(StringBuilder strInvoiceItem, List<InvoicePaymentEmailInfo> paymentMethodList)
		{
			// Cash row
			if (paymentMethodList.Any(s => s.CategoryName.ToLower() == "card"))
			{
				var cardMethodName = paymentMethodList.FirstOrDefault(s => s.CategoryName.ToLower() == "card").CategoryName;

				var cardRecord = paymentMethodList.Where(s => s.CategoryName.ToLower() == "card").ToList();

				foreach (var item in cardRecord.Where(s => s.PaymentAmount != null && s.PaymentAmount > 0).ToList())
					item.PaymentReferenceNumber = string.IsNullOrEmpty(item.PaymentReferenceNumber) ? string.Empty : item.PaymentReferenceNumber;

				var cardPaymentReferenceNumber = string.Join(", ", cardRecord.Select(s => s.PaymentMethodName + "-" + s.PaymentReferenceNumber));

				strInvoiceItem.Append(@"
				<tr>
					<td style='background-color:#f2f2f2;'>" + cardMethodName + @"</td>
					<td style='text-align:left; background-color:#f2f2f2;'>" + cardPaymentReferenceNumber + @"</td>
					<td style='text-align:right; background-color:#f2f2f2;'>" + (cardRecord.Sum(s => s.PaymentAmount) > 0 ? cardRecord.Sum(s => s.PaymentAmount).ToTwoDecimalString() : "") + @"</td>
				</tr>");
			}
			else
			{
				strInvoiceItem.Append(@"
				<tr>
					<td style='background-color:#f2f2f2;'> Card </td>
					<td style='text-align:left; background-color:#f2f2f2;'></td>
					<td style='text-align:right; background-color:#f2f2f2;'></td>
				</tr>");
			}
		}
		private void AddChequeNoRow(StringBuilder strInvoiceItem, List<InvoicePaymentEmailInfo> paymentMethodList)
		{
			// Cash row
			if (paymentMethodList.Any(s => s.CategoryName.ToLower() == "cheque no"))
			{
				var checkRecord = paymentMethodList.Where(s => s.CategoryName.ToLower() == "cheque no").ToList();

				var chequeNoMethodName = paymentMethodList.FirstOrDefault(s => s.CategoryName.ToLower() == "cheque no").CategoryName;

				strInvoiceItem.Append(@"
				<tr>
					<td style='background-color:#f2f2f2;'>" + chequeNoMethodName + @"</td>
					<td style='text-align:left;background-color:#f2f2f2;'>" + checkRecord?.FirstOrDefault()?.PaymentReferenceNumber + @"</td>
					<td style='text-align:right;background-color:#f2f2f2;'>" + (checkRecord.Sum(s => s.PaymentAmount) > 0 ? checkRecord.Sum(s => s.PaymentAmount).ToTwoDecimalString() : "") + @"</td>
				</tr>");
			}
			else
			{
				strInvoiceItem.Append(@"
				<tr>
					<td style='background-color:#f2f2f2;'> Cheque No </td>
					<td style='text-align:left; background-color:#f2f2f2;'></td>
					<td style='text-align:right; background-color:#f2f2f2;'></td>
				</tr>");
			}
		}

		private void AddWireTransferRow(StringBuilder strInvoiceItem, List<InvoicePaymentEmailInfo> paymentMethodList)
		{
			// Cash row
			if (paymentMethodList.Any(s => s.CategoryName.ToLower() == "wire transfer"))
			{
				var bankRecord = paymentMethodList.Where(s => s.CategoryName.ToLower() == "wire transfer").ToList();

				var wireTransferMethodName = paymentMethodList.FirstOrDefault(s => s.CategoryName.ToLower() == "wire transfer").CategoryName;

				strInvoiceItem.Append(@"
				<tr>
					<td style='background-color:#f2f2f2;'>" + wireTransferMethodName + @"</td>
					<td style='text-align:left;background-color:#f2f2f2;'>" + bankRecord?.FirstOrDefault()?.PaymentReferenceNumber + @"</td>
					<td style='text-align:right;background-color:#f2f2f2;'>" + (bankRecord.Sum(s => s.PaymentAmount) > 0 ? bankRecord.Sum(s => s.PaymentAmount).ToTwoDecimalString() : "") + @"</td>
				</tr>");
			}
			else
			{
				strInvoiceItem.Append(@"
				<tr>
					<td style='background-color:#f2f2f2;'> Wire Transfer </td>
					<td style='text-align:left; background-color:#f2f2f2;'></td>
					<td style='text-align:right; background-color:#f2f2f2;'></td>
				</tr>");
			}
		}

		private void AddCashRow(StringBuilder strInvoiceItem, List<InvoicePaymentEmailInfo> paymentMethodList)
		{
			// Cash row
			if (paymentMethodList.Any(s => s.CategoryName.ToLower() == "cash"))
			{
				var cashRecord = paymentMethodList.Where(s => s.CategoryName.ToLower().Contains("cash")).ToList();

				var cashMethodName = paymentMethodList.FirstOrDefault(s => s.CategoryName.ToLower() == "cash").CategoryName;

				strInvoiceItem.Append(@"
				<tr>
					<td style='background-color:#f2f2f2;'>" + cashMethodName + @"</td>
					<td style='text-align:left; background-color:#f2f2f2;'>" + cashRecord?.FirstOrDefault()?.PaymentReferenceNumber + @"</td>
					<td style='text-align:right; background-color:#f2f2f2;'>" + (cashRecord.Sum(s => s.PaymentAmount) > 0 ? cashRecord.Sum(s => s.PaymentAmount).ToTwoDecimalString() : "") + @"</td>
				</tr>");
			}
			else
			{
				strInvoiceItem.Append(@"
				<tr>
					<td style='background-color:#f2f2f2;'> Cash </td>
					<td style='text-align:left; background-color:#f2f2f2;'></td>
					<td style='text-align:right; background-color:#f2f2f2;'></td>
				</tr>");
			}
		}

		private void AddBankDetail(StringBuilder strInvoiceItem)
		{
			strInvoiceItem.Append(@"
<table cellpadding='4' cellspacing='0' style='border-collapse:collapse;text-align:left; float:right;width:70%;font-size:10px;'>
    <tr>
        <th colspan='2' style='text-align:left;font-weight:bold;background-color:white;padding-bottom:10px;'>BANK DETAILS</th>
    </tr>
    <tr>
        <td style='width:30%; background-color: #00b0f0; color:#FFF;'>Account Name</td>
        <td style='background-color:#f2f2f2;'>: Advance Learning Company Ltd</td>
    </tr>
    <tr>
        <td style='background-color: #00b0f0; color:#FFF;'>Bank</td>
        <td style='background-color:#f2f2f2;'>: EMIRATES NBD</td>
    </tr>
    <tr>
        <td style='background-color: #00b0f0; color:#FFF;'>Branch</td>
        <td style='background-color:#f2f2f2;'>: Riyadh, Saudi Arabia</td>
    </tr>
    <tr>
        <td style='background-color: #00b0f0; color:#FFF;'>Account No</td>
        <td style='background-color:#f2f2f2;'>: 1016046166901</td>
    </tr>
    <tr>
        <td style='background-color: #00b0f0; color:#FFF;'>Swift Code</td>
        <td style='background-color:#f2f2f2;'>: EBILAEADXXX</td>
    </tr>
    <tr>
        <td style='background-color: #00b0f0;color:#FFF;'>IBAN</td>
        <td style='background-color:#f2f2f2;'>: SA6095000001016046166901</td>
    </tr>
</table>
");
		}

		private string GetTemplateBody(string key,string rootpath)
		{
			string body = string.Empty;
			try
			{
				
				XmlDocument xDoc = new XmlDocument();
				var ConfigPath = $"{Path.Combine(rootpath, "Configurations", "EmailTemplates")}/mailtemplate.config";
				xDoc.Load(ConfigPath);
				XmlNode oXmlNode = xDoc.SelectSingleNode(".//template[@active='yes' and @id='" + key.ToLower() + "']/body");

				if (oXmlNode != null)
				{
					body = oXmlNode.InnerText;
				}
			}
			catch (Exception)
			{
			}
			return body;
		}

		//   private string CreateInvoiceItemUniformDetail(string invoiceNo)
		//   {
		//       try
		//       {
		//           var invoiceMaster = _zATCAInvoiceContext.InvoiceSummaries.FirstOrDefault(s => s.InvoiceNo == invoiceNo);

		//           //var invoiceItemList = _zATCAInvoiceContext.InvoiceDetails.Where(s => s.InvoiceNo == invoiceNo).ToList();
		//           var uniformDetails = _zATCAInvoiceContext.UniformDetails.Where(s => s.InvoiceNo == invoiceNo).ToList();
		//           StringBuilder strInvoiceItem = new StringBuilder();

		//           // Line item header
		//           strInvoiceItem.Append(@"<table border='1'  cellpadding='0' cellspacing='0' bordercolor='#999999' style='border-collapse:collapse; font-size:10px;float:left;width:100%;'>
		//<tr style='background: #00b0f0;'>
		//    <td colspan='9' align='left' valign='middle'>
		//        <table border='0'  cellpadding='0' cellspacing='0' bordercolor='#999999' style='border-collapse:collapse; font-size:10px;float:left;width:100%;'>
		//            <tr>
		//                <td align='left'><strong>Description</strong></td>
		//                <td align='right'><strong>توصيف السلعة او الخدمة</strong></td>
		//            </tr>
		//        </table>

		//    </td>
		//</tr>
		//<tr>
		//    <td><strong>Description / التفاصيل</strong></td>
		//    <td><strong>Quantity (الكمية)</strong></td>
		//    <td><strong>Unit Price (السعرالوحدة)</strong></td>
		//    <td><strong>Grade / درجة</strong></td>
		//    <td><strong>Taxable Amount المبلغ الخاضع للضريبة</strong></td>
		//    <td><strong>Discount خصومات</strong></td>
		//    <td><strong>Tax Rate نسبة الضريبة</strong></td>
		//    <td><strong>Tax Amount  مبلغ الضريبة</strong></td>
		//    <td><strong>Item Subtotal Incl VAT المجموع (شامل ضربية القيمة المضافة)</strong></td>
		//</tr>");

		//           decimal totalTaxableAmount = 0;
		//           decimal totalDiscount = 0;
		//           decimal totalTaxAmount = 0;
		//           decimal totalItemSubtotal = 0;

		//           string invoiceDate = invoiceMaster.InvoiceDate.HasValue ? invoiceMaster.InvoiceDate.Value.ToString("dd-MM-yyyy") : string.Empty;

		//           string bankTransfer = invoiceMaster.PaymentMethod.ToLower().Contains("bank")
		//               ? invoiceMaster.ChequeNo : string.Empty;
		//           string bankTransferInvoiceDate = invoiceMaster.PaymentMethod.ToLower().Contains("bank") && invoiceMaster.InvoiceDate.HasValue
		//          ? invoiceMaster.InvoiceDate.Value.ToString("dd-MM-yyyy") : string.Empty;

		//           string checkNo = invoiceMaster.PaymentMethod.ToLower().Contains("check")
		//             ? invoiceMaster.ChequeNo : string.Empty;
		//           string checkInvoiceDate = invoiceMaster.PaymentMethod.ToLower().Contains("check") && invoiceMaster.InvoiceDate.HasValue
		//           ? invoiceMaster.InvoiceDate.Value.ToString("dd-MM-yyyy") : string.Empty;

		//           string cardName = invoiceMaster.PaymentMethod.ToLower().Contains("visa")
		//               || invoiceMaster.PaymentMethod.ToLower().Contains("mada")
		//               || invoiceMaster.PaymentMethod.ToLower().Contains("master")
		//          ? invoiceMaster.PaymentMethod : string.Empty;

		//           string cardInvoiceDate = (invoiceMaster.PaymentMethod.ToLower().Contains("visa")
		//               || invoiceMaster.PaymentMethod.ToLower().Contains("mada")
		//               || invoiceMaster.PaymentMethod.ToLower().Contains("master")) && invoiceMaster.InvoiceDate.HasValue
		//              ? invoiceMaster.InvoiceDate.Value.ToString("dd-MM-yyyy") : string.Empty;

		//           string cashMethod = invoiceMaster.PaymentMethod.ToLower().Contains("cash") ? "Cash" : string.Empty;
		//           string cashInvoiceDate = invoiceMaster.PaymentMethod.ToLower().Contains("cash") && invoiceMaster.InvoiceDate.HasValue
		//              ? invoiceMaster.InvoiceDate.Value.ToString("dd-MM-yyyy") : string.Empty;

		//           //Line item recods
		//           uniformDetails.ForEach(s =>
		//           {
		//               var description = string.Format("<td style='border-top:1px solid #ddd'>{0}</td>", s.Description);
		//               var quanitity = string.Format("<td style='text-align:right;border-top:1px solid #ddd'>{0}</td>", s.Quantity.ToString());
		//               var unitPrice = string.Format("<td style='text-align:right;border-top:1px solid #ddd'>{0}</td>", Convert.ToDecimal(s.UnitPrice).ToTwoDecimalString());
		//               var grade = string.Format("<td style='text-align:right;border-top:1px solid #ddd'>{0}</td>", s.Grade.ToString());
		//               var TaxableAmount = string.Format("<td style='text-align:right;border-top:1px solid #ddd'>{0}</td>", Convert.ToDecimal(s.TaxableAmount).ToTwoDecimalString());
		//               var discount = string.Format("<td style = 'text-align:right;border-top:1px solid #ddd' > {0} </td >", Convert.ToDecimal(s.Discount).ToTwoDecimalString());
		//               var taxRate = string.Format("<td style = 'text-align:right;border-top:1px solid #ddd' > {0} </td >", Convert.ToDecimal(s.TaxRate).ToTwoDecimalString());
		//               var taxAmount = string.Format("<td style = 'text-align:right;border-top:1px solid #ddd' > {0} </td >", Convert.ToDecimal(s.TaxAmount).ToTwoDecimalString());
		//               var itemSubtotal = string.Format("<td style = 'text-align:right;border-top:1px solid #ddd' > {0} </td >", Convert.ToDecimal(s.ItemSubtotal).ToTwoDecimalString());

		//               totalTaxableAmount += string.IsNullOrEmpty(s.TaxableAmount) ? 0 : Convert.ToDecimal(s.TaxableAmount);
		//               totalDiscount += string.IsNullOrEmpty(s.Discount) ? 0 : Convert.ToDecimal(s.Discount);
		//               totalTaxAmount += string.IsNullOrEmpty(s.TaxAmount) ? 0 : Convert.ToDecimal(s.TaxAmount);
		//               totalItemSubtotal += string.IsNullOrEmpty(s.ItemSubtotal) ? 0 : Convert.ToDecimal(s.ItemSubtotal);

		//               strInvoiceItem.Append(@"<tr>");
		//               strInvoiceItem.Append(description);
		//               strInvoiceItem.Append(quanitity);
		//               strInvoiceItem.Append(unitPrice);
		//               strInvoiceItem.Append(grade);

		//               strInvoiceItem.Append(TaxableAmount);
		//               strInvoiceItem.Append(discount);
		//               strInvoiceItem.Append(taxRate);
		//               strInvoiceItem.Append(taxAmount);
		//               strInvoiceItem.Append(itemSubtotal);
		//               strInvoiceItem.Append(@"</tr>");
		//           });

		//           //Add total Line
		//           var descriptionNewTotal = string.Format("<td style='border-top:1px solid #ddd'>{0}</td>", "Total Amount: (أجمالي المبالغ)");
		//           var emptyCell = string.Format("<td style='border-top:1px solid #ddd'>{0}</td>", "");

		//           var TaxableAmountNewTotal = string.Format("<td style='text-align:right;border-top:1px solid #ddd'>{0}</td>", totalTaxableAmount.ToTwoDecimalString());
		//           var discountNewTotal = string.Format("<td style = 'text-align:right;border-top:1px solid #ddd' > {0} </td >", totalDiscount.ToTwoDecimalString());
		//           var taxRateNewTotal = string.Format("<td style = 'text-align:right;border-top:1px solid #ddd' > {0} </td >", "");
		//           var taxAmountNewTotal = string.Format("<td style = 'text-align:right;border-top:1px solid #ddd' > {0} </td >", totalTaxAmount.ToTwoDecimalString());
		//           var itemSubtotalNewTotal = string.Format("<td style = 'text-align:right;border-top:1px solid #ddd' > {0} </td >", totalItemSubtotal.ToTwoDecimalString());

		//           strInvoiceItem.Append(@"<tr style='background: #00b0f0;'>");
		//           strInvoiceItem.Append(descriptionNewTotal);
		//           strInvoiceItem.Append(emptyCell);
		//           strInvoiceItem.Append(emptyCell);
		//           strInvoiceItem.Append(emptyCell);
		//           strInvoiceItem.Append(TaxableAmountNewTotal);
		//           strInvoiceItem.Append(discountNewTotal);
		//           strInvoiceItem.Append(taxRateNewTotal);
		//           strInvoiceItem.Append(taxAmountNewTotal);
		//           strInvoiceItem.Append(itemSubtotalNewTotal);
		//           strInvoiceItem.Append(@"</tr>");

		//           //Bottom Line
		//           strInvoiceItem.Append(@"</table><br /><br /><br /><br />");

		//           //Payment Table
		//           AddPaymentInfo(strInvoiceItem, invoiceMaster, totalTaxableAmount, totalDiscount, totalTaxAmount, totalItemSubtotal);

		//           strInvoiceItem.Append("</table>");
		//           return strInvoiceItem.ToString();
		//       }
		//       catch (Exception ex)
		//       {
		//           throw ex;
		//       }

		//   }

		//   string GetTemplateSubject(string key)
		//   {
		//       string subject = string.Empty;
		//       try
		//       {
		//           XmlDocument xDoc = new XmlDocument();
		//           var ConfigPath = $"{Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Configurations", "EmailTemplates")}/mailtemplate.config";
		//           xDoc.Load(ConfigPath);
		//           XmlNode oXmlNode = xDoc.SelectSingleNode(".//template[@active='yes' and @id='" + key.ToLower() + "']/subject");
		//           if (oXmlNode != null)
		//           {
		//               subject = oXmlNode.InnerText;
		//           }
		//       }
		//       catch (Exception)
		//       {
		//       }
		//       return subject;
		//   }

	}
}