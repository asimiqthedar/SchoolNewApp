using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using School.Common;
using School.Models.WebModels;
using School.Services.WebServices.Services;
using System.Data;

namespace School.Web.Controllers
{
	[Authorize]
    public class AttachmentController : BaseController
    {
        private readonly ILogger<AttachmentController> _logger;
        private IAttachements _IAttachements;
        IOptions<AppSettingConfig> _AppSettingConfig;
        IHttpContextAccessor _IHttpContextAccessor;
        private readonly IWebHostEnvironment _IWebHostEnvironment;
        public AttachmentController(ILogger<AttachmentController> logger, IOptions<AppSettingConfig> appSettingConfig, IAttachements iIAttachements, IHttpContextAccessor iHttpContextAccessor, IDropdownService iDropdownService, IWebHostEnvironment iWebHostEnvironment) : base(iHttpContextAccessor, iDropdownService)
        {
            _logger = logger;
            _AppSettingConfig = appSettingConfig;
            _IAttachements = iIAttachements;
            _IHttpContextAccessor = iHttpContextAccessor;
            _IWebHostEnvironment = iWebHostEnvironment;
        }

        public async Task<IActionResult> UploadAttachmentPartial(int DocFor, long DocForId)
        {
            InitDropdown();
            ViewBag.DocFor = DocFor;
            ViewBag.DocForId = DocForId;
            return PartialView("_UploadAttachmentPartial");
        }

        [HttpPost]
        public async Task<IActionResult> UploadAttachment(IFormCollection iFormCollection)
        {
            try
            {
                var attachmentFile = iFormCollection.Files["attachment"];
                int DocFor = Convert.ToInt32(iFormCollection["DocFor"]);
                int DocType = Convert.ToInt32(iFormCollection["DocType"]);
                long DocForId = Convert.ToInt64(iFormCollection["DocForId"]);
                string DocNo = Convert.ToString(iFormCollection["DocNo"]);
                string DocPath = string.Empty;
                if (attachmentFile != null && attachmentFile.Length > 0)
                {
                    string folderPath = Path.Combine(_IWebHostEnvironment.WebRootPath, "uploads", "documents", "parentdoc", Convert.ToString(DocForId));
                    if (!Directory.Exists(folderPath))
                        Directory.CreateDirectory(folderPath);
                    string fileName = Path.GetFileNameWithoutExtension(attachmentFile.FileName) + "_" + DateTime.Now.ToString("ddMMyyyy-HH-mm") + Path.GetExtension(attachmentFile.FileName);
                    DocPath = Path.Combine(folderPath, fileName);
                    using (var stream = new FileStream(Path.Combine(folderPath, fileName), FileMode.Create))
                    {
                        await attachmentFile.CopyToAsync(stream);
                    }
                    if (!string.IsNullOrEmpty(DocPath))
                    {
                        return Json(new { result = await _IAttachements.SaveAttachements(DocFor, DocType, DocForId, DocNo, DocPath, Convert.ToInt32(GetUserDataFromClaims("UserId"))) });
                    }
                    else
                    {
                        return Json(new { result = -3 });
                    }
                }
                return Json(new { result = -1 });
            }
            catch (Exception)
            {
                throw;
            }
        }

        public async Task<IActionResult> GetAttachmentPartial(int docForId, int docFor)
        {
            var model = await _IAttachements.GetAttachments(docForId, docFor);
            foreach (DataRow row in model.Tables[0].Rows)
            {
                string rowValue = Convert.ToString(row["DocPath"]);
                row["DocPath"] = rowValue.Replace(_IWebHostEnvironment.WebRootPath, _AppSettingConfig.Value.VertualDirectoryPath);
            }
            return PartialView("_AttachmentsPartial", model);
        }

        public async void InitDropdown()
        {
            ViewBag.DocumentTypeDropdown = await GetAppDropdown(AppDropdown.DocumentType, true);
        }


        public async Task<IActionResult> DeleteAttachment(int uploadedDocId)
        {
            try
            {
                return Json(new { result = await _IAttachements.DeleteAttachment(uploadedDocId, Convert.ToInt32(GetUserDataFromClaims("UserId"))) });
            }
            catch (Exception)
            {
                throw;
            }

        }
    }
}
