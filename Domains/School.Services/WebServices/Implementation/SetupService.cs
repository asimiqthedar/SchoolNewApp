using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using School.Database.WebRepos;
using School.Models.WebModels;
using School.Models.WebModels.ConfigModel;
using School.Models.WebModels.CostCenterModels;
using School.Models.WebModels.DiscountModels;
using School.Models.WebModels.DocumentTypeModels;
using School.Models.WebModels.GenderModels;
using School.Models.WebModels.GradeModels;
using School.Models.WebModels.InvoiceTypeModels;
using School.Models.WebModels.PaymentMethod;
using School.Models.WebModels.SectionModels;
using School.Models.WebModels.StudentStatus;
using School.Models.WebModels.VatModels;
using School.Services.WebServices.Services;
using System.Data;

namespace School.Services.WebServices.Implementation
{
	public class SetupService : ISetupService
    {
        SetupRepo _SetupRepo;
        private readonly ILogger<SetupService> _logger;
        public SetupService(IOptions<AppSettingConfig> appSettingConfig, ILogger<SetupService> logger)
        {
            _SetupRepo = new SetupRepo(appSettingConfig);
            _logger = logger;
        }

        #region Cost Center
        public async Task<int> DeleteCostCenter(int loginUserId, int costCenterId)
        {
            try
            {
                int result = await _SetupRepo.DeleteCostCenter(loginUserId, costCenterId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:DeleteCostCenter : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<CostCenterModel> GetCostCenterById(int costCenterId)
        {
            try
            {
                CostCenterModel model = new CostCenterModel();
                DataSet ds = await _SetupRepo.GetCostCenters(costCenterId, new CostCenterFilterModel());
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.CostCenterId = Convert.ToInt32(ds.Tables[0].Rows[0]["CostCenterId"]);
                    model.CostCenterName = Convert.ToString(ds.Tables[0].Rows[0]["CostCenterName"]);
                    model.Remarks = Convert.ToString(ds.Tables[0].Rows[0]["Remarks"]);
                    model.IsActive = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsActive"]);
                }
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:GetCostCenterById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<DataSet> GetCostCenters(CostCenterFilterModel filterModel)
        {
            try
            {
                DataSet ds = await _SetupRepo.GetCostCenters(0, filterModel);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:GetCostCenters : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<int> SaveCostCenter(int loginUserId, CostCenterModel model)
        {
            try
            {
                int result = await _SetupRepo.SaveCostCenter(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:SaveCostCenter : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion

        #region Gender
        public async Task<int> DeleteGender(int loginUserId, int genderTypeId)
        {
            try
            {
                int result = await _SetupRepo.DeleteGender(loginUserId, genderTypeId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:DeleteGender : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<GenderModel> GetGenderById(int genderTypeId)
        {
            try
            {
                GenderModel model = new GenderModel();
                DataSet ds = await _SetupRepo.GetGenders(genderTypeId, new GenderFilterModel());
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.GenderTypeId = Convert.ToInt32(ds.Tables[0].Rows[0]["GenderTypeId"]);
                    model.GenderTypeName = Convert.ToString(ds.Tables[0].Rows[0]["GenderTypeName"]);
                    model.DebitAccount = Convert.ToString(ds.Tables[0].Rows[0]["DebitAccount"]);
                    model.CreditAccount = Convert.ToString(ds.Tables[0].Rows[0]["CreditAccount"]);
                    model.IsActive = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsActive"]);
                }
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:GetGenderById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<DataSet> GetGenders(GenderFilterModel filterModel)
        {
            try
            {
                DataSet ds = await _SetupRepo.GetGenders(0, filterModel);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:GetGenders : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<int> SaveGender(int loginUserId, GenderModel model)
        {
            try
            {
                int result = await _SetupRepo.SaveGender(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:SaveGender : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion

        #region Grade
        public async Task<int> AdjustGrade(int gradeId, int value, int sequenceNo)
        {
            try
            {
                int result = await _SetupRepo.AdjustGrade(gradeId, value, sequenceNo);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:AdjustGrade : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> DeleteGrade(int loginUserId, int gradeId)
        {
            try
            {
                int result = await _SetupRepo.DeleteGrade(loginUserId, gradeId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:DeleteGrade : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<GradeModel> GetGradeById(int gradeId)
        {
            try
            {
                GradeModel model = new GradeModel();
                DataSet ds = await _SetupRepo.GetGrades(gradeId, new GradeFilterModel());
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.GradeId = Convert.ToInt32(ds.Tables[0].Rows[0]["GradeId"]);
                    model.GradeName = Convert.ToString(ds.Tables[0].Rows[0]["GradeName"]);
                    model.SequenceNo = Convert.ToInt32(ds.Tables[0].Rows[0]["SequenceNo"]);
                    model.MaxSequenceNo = Convert.ToInt32(ds.Tables[0].Rows[0]["MaxSequenceNo"]);
                    model.CostCenterId = Convert.ToInt32(ds.Tables[0].Rows[0]["CostCenterId"]);
                    model.CostCenterName = Convert.ToString(ds.Tables[0].Rows[0]["CostCenterName"]);
                    model.GenderTypeId = Convert.ToInt32(ds.Tables[0].Rows[0]["GenderTypeId"]);
                    model.GenderTypeName = Convert.ToString(ds.Tables[0].Rows[0]["GenderTypeName"]);
                    model.DebitAccount = Convert.ToString(ds.Tables[0].Rows[0]["DebitAccount"]);
                    model.CreditAccount = Convert.ToString(ds.Tables[0].Rows[0]["CreditAccount"]);
                    model.IsActive = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsActive"]);
                }

                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:GetGradeById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<GradeModel> GetGradeMaxSequenceNo()
        {
            try
            {
                GradeModel model = new GradeModel();
                DataSet ds = await _SetupRepo.GetGradeMaxSequenceNo();
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.SequenceNo = Convert.ToInt32(ds.Tables[0].Rows[0]["SequenceNo"]) + 1;
                }
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:GetGradeMaxSequenceNo : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<DataSet> GetGrades(GradeFilterModel filterModel)
        {
            try
            {
                DataSet ds = await _SetupRepo.GetGrades(0, filterModel);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:GetGrades : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<int> SaveGrade(int loginUserId, GradeModel model)
        {
            try
            {
                int result = await _SetupRepo.SaveGrade(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:SaveGrade : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion

        #region Document Type
        public async Task<int> DeleteDocumentType(int loginUserId, int documentTypeId)
        {
            try
            {
                int result = await _SetupRepo.DeleteDocumentType(loginUserId, documentTypeId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:DeleteDocumentType : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<DocumentTypeModel> GetDocumentTypeById(int documentTypeId)
        {
            try
            {
                DocumentTypeModel model = new DocumentTypeModel();
                DataSet ds = await _SetupRepo.GetDocumentType(documentTypeId, new DocumentTypeFilterModel());
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.DocumentTypeId = Convert.ToInt32(ds.Tables[0].Rows[0]["DocumentTypeId"]);
                    model.DocumentTypeName = Convert.ToString(ds.Tables[0].Rows[0]["DocumentTypeName"]);
                    model.Remarks = Convert.ToString(ds.Tables[0].Rows[0]["Remarks"]);
                    model.IsActive = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsActive"]);
                }
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:GetDocumentTypeById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<DataSet> GetDocumentType(DocumentTypeFilterModel filterModel)
        {
            try
            {
                DataSet ds = await _SetupRepo.GetDocumentType(0, filterModel);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:GetDocumentType : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<int> SaveDocumentType(int loginUserId, DocumentTypeModel model)
        {
            try
            {
                int result = await _SetupRepo.SaveDocumentType(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:SaveDocumentType : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion

        #region Section
        public async Task<int> DeleteSection(int loginUserId, int sectionId)
        {
            try
            {
                int result = await _SetupRepo.DeleteSection(loginUserId, sectionId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:DeleteSection : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<SectionModel> GetSectionById(int sectionId)
        {
            try
            {
                SectionModel model = new SectionModel();
                DataSet ds = await _SetupRepo.GetSections(sectionId, new SectionFilterModel());
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.SectionId = Convert.ToInt32(ds.Tables[0].Rows[0]["SectionId"]);
                    model.SectionName = Convert.ToString(ds.Tables[0].Rows[0]["SectionName"]);
                    model.IsActive = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsActive"]);
                }
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:GetSectionById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<DataSet> GetSections(SectionFilterModel filterModel)
        {
            try
            {
                DataSet ds = await _SetupRepo.GetSections(0, filterModel);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:GetSections : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<int> SaveSection(int loginUserId, SectionModel model)
        {
            try
            {
                int result = await _SetupRepo.SaveSection(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:SaveSection : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion

        #region Invoice Type
        public async Task<int> DeleteInvoiceType(int loginUserId, int invoiceTypeId)
        {
            try
            {
                int result = await _SetupRepo.DeleteInvoiceType(loginUserId, invoiceTypeId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:DeleteInvoiceType : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<InvoiceTypeModel> GetInvoiceTypeById(int invoiceTypeId)
        {
            try
            {
                InvoiceTypeModel model = new InvoiceTypeModel();
                DataSet ds = await _SetupRepo.GetInvoiceType(invoiceTypeId, new InvoiceTypeFilterModel());
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.InvoiceTypeId = Convert.ToInt32(ds.Tables[0].Rows[0]["InvoiceTypeId"]);
                    model.InvoiceTypeName = Convert.ToString(ds.Tables[0].Rows[0]["InvoiceTypeName"]);
                    model.ReceivableAccount = Convert.ToString(ds.Tables[0].Rows[0]["ReceivableAccount"]);
                    model.AdvanceAccount = Convert.ToString(ds.Tables[0].Rows[0]["AdvanceAccount"]);
                    model.ReceivableAccountRemarks = Convert.ToString(ds.Tables[0].Rows[0]["ReceivableAccountRemarks"]);
                    model.AdvanceAccountRemarks = Convert.ToString(ds.Tables[0].Rows[0]["AdvanceAccountRemarks"]);
                    model.IsActive = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsActive"]);
                }
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:GetInvoiceTypeById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<DataSet> GetInvoiceType(InvoiceTypeFilterModel filterModel)
        {
            try
            {
                DataSet ds = await _SetupRepo.GetInvoiceType(0, filterModel);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:GetInvoiceType : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<int> SaveInvoiceType(int loginUserId, InvoiceTypeModel model)
        {
            try
            {
                int result = await _SetupRepo.SaveInvoiceType(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:SaveInvoiceType : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion

        #region Student Status
        public async Task<int> DeleteStudentStatus(int loginUserId, int studentStatusId)
        {
            try
            {
                int result = await _SetupRepo.DeleteStudentStatus(loginUserId, studentStatusId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:DeleteStudentstatus : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<StudentStatusModel> GetStudentStatusById(int studentStatusId)
        {
            try
            {
                StudentStatusModel model = new StudentStatusModel();
                DataSet ds = await _SetupRepo.GetStudentStatus(studentStatusId, new StudentStatusFilterModel());
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.StudentStatusId = Convert.ToInt32(ds.Tables[0].Rows[0]["StudentStatusId"]);
                    model.StatusName = Convert.ToString(ds.Tables[0].Rows[0]["StatusName"]);

                    model.IsActive = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsActive"]);
                }
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:GetStudentStatusById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<DataSet> GetStudentStatus(StudentStatusFilterModel filterModel)
        {
            try
            {
                DataSet ds = await _SetupRepo.GetStudentStatus(0, filterModel);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:GetStudentStatus : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<int> SaveStudentStatus(int loginUserId, StudentStatusModel model)
        {
            try
            {
                int result = await _SetupRepo.SaveStudentStatus(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:SaveStudentStatus : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion

        #region OpenApply      

        public async Task<OpenApplyModel> GetGetOpenApply(int openApplyId)
        {
            try
            {
                OpenApplyModel model = new OpenApplyModel();
                DataSet ds = await _SetupRepo.GetOpenApply(openApplyId, new GenderFilterModel());
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.OpenApplyId = Convert.ToInt32(ds.Tables[0].Rows[0]["OpenApplyId"]);

                    model.GrantType = Convert.ToString(ds.Tables[0].Rows[0]["GrantType"]);
                    model.ClientId = Convert.ToString(ds.Tables[0].Rows[0]["ClientId"]);
                    model.ClientSecret = Convert.ToString(ds.Tables[0].Rows[0]["ClientSecret"]);
                    model.Audience = Convert.ToString(ds.Tables[0].Rows[0]["Audience"]);
                    model.OpenApplyJobPath = Convert.ToString(ds.Tables[0].Rows[0]["OpenApplyJobPath"]);

                    model.IsActive = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsActive"]);
                }
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:GetGetOpenApply : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<int> SaveOpenApply(int loginUserId, OpenApplyModel model)
        {
            try
            {
                int result = await _SetupRepo.SaveOpenApply(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:SaveOpenApply : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion

        #region Vat
        public async Task<int> DeleteVat(int loginUserId, int vatId)
        {
            try
            {
                int result = await _SetupRepo.DeleteVat(loginUserId, vatId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:DeleteVat : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<VatModel> GetVatById(int vatId)
        {
            try
            {
                VatModel model = new VatModel();
                DataSet ds = await _SetupRepo.GetVats(vatId);
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.VatId = Convert.ToInt32(ds.Tables[0].Rows[0]["VatId"]);
                    model.FeeTypeId = Convert.ToInt32(ds.Tables[0].Rows[0]["FeeTypeId"]);
                    model.FeeTypeName = Convert.ToString(ds.Tables[0].Rows[0]["FeeTypeName"]);
                    model.VatTaxPercent = Convert.ToDecimal(ds.Tables[0].Rows[0]["VatTaxPercent"]);
                    model.DebitAccount = Convert.ToString(ds.Tables[0].Rows[0]["DebitAccount"]);
                    model.CreditAccount = Convert.ToString(ds.Tables[0].Rows[0]["CreditAccount"]);
                    model.CountryExcludeCount = Convert.ToInt32(ds.Tables[0].Rows[0]["CountryExcludeCount"]);
                }
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:GetVatById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<DataSet> GetVats()
        {
            try
            {
                DataSet ds = await _SetupRepo.GetVats(0);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:GetVats : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<int> SaveVat(int loginUserId, VatModel model)
        {
            try
            {
                int result = await _SetupRepo.SaveVat(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:SaveVat : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #region Vat Exempted Nation Mapping
        public async Task<DataSet> GetVatExemptedNationMapping(long vatId)
        {
            try
            {
                DataSet ds = await _SetupRepo.GetVatExemptedNationMapping(vatId);
                return ds;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task<int> SaveVatExemptedNationMapping(int loginUserId, VatExemptedNationModel model)
        {
            try
            {
                int result = await _SetupRepo.SaveVatExemptedNationMapping(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        #endregion
        #endregion

        #region Discount
        public async Task<int> DeleteSiblingDiscount(int loginUserId, int discountId)
        {
            try
            {
                int result = await _SetupRepo.DeleteSiblingDiscount(loginUserId, discountId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:DeleteDiscount : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<DiscountModel> GetSiblingDiscountById(int discountId)
        {
            try
            {
                DiscountModel model = new DiscountModel();
                DataSet ds = await _SetupRepo.GetSiblingDiscounts(discountId);
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.DiscountId = Convert.ToInt32(ds.Tables[0].Rows[0]["DiscountId"]);
                    model.ChildrenNo = Convert.ToInt32(ds.Tables[0].Rows[0]["ChildrenNo"]);
                    model.DiscountPercent = Convert.ToDecimal(ds.Tables[0].Rows[0]["DiscountPercent"]);
					model.StaffDiscountPercent = Convert.ToDecimal(ds.Tables[0].Rows[0]["StaffDiscountPercent"]);
				}
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:GetDiscountById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<DataSet> GetSiblingDiscounts()
        {
            try
            {
                DataSet ds = await _SetupRepo.GetSiblingDiscounts(0);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:GetDiscounts : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> SaveSiblingDiscount(int loginUserId, DiscountModel model)
        {
            try
            {
                int result = await _SetupRepo.SaveSiblingDiscount(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:SaveDiscount : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion

        #region Email      

        public async Task<EmailConfigModel> GetEmailConfig(int emailConfigId)
        {
            try
            {
                EmailConfigModel model = new EmailConfigModel();
                DataSet ds = await _SetupRepo.GetEmailConfig(emailConfigId);
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.EmailConfigId = Convert.ToInt32(ds.Tables[0].Rows[0]["EmailConfigId"]);
                    model.Host = Convert.ToString(ds.Tables[0].Rows[0]["Host"]);
                    model.Port = Convert.ToInt32(ds.Tables[0].Rows[0]["Port"]);
                    model.Username = Convert.ToString(ds.Tables[0].Rows[0]["Username"]);
                    model.Password = Convert.ToString(ds.Tables[0].Rows[0]["Password"]);
                    model.EnableSSL = Convert.ToBoolean(ds.Tables[0].Rows[0]["EnableSSL"]);
                    model.FromEmail = Convert.ToString(ds.Tables[0].Rows[0]["FromEmail"]);
                }
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:GetEmailConfig : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<int> SaveEmailConfig(int loginUserId, EmailConfigModel model)
        {
            try
            {
                int result = await _SetupRepo.SaveEmailConfig(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:SaveEmailConfig : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion

        #region Whatsapp      

        public async Task<WhatsappConfigModel> GetWhatsappConfig(int whatsappConfigId)
        {
            try
            {
                WhatsappConfigModel model = new WhatsappConfigModel();
                DataSet ds = await _SetupRepo.GetWhatsappConfig(whatsappConfigId);
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.WhatsAppConfigId = Convert.ToInt32(ds.Tables[0].Rows[0]["WhatsAppConfigId"]);
                    model.AccountSid = Convert.ToString(ds.Tables[0].Rows[0]["AccountSid"]);
                    model.AuthToken = Convert.ToString(ds.Tables[0].Rows[0]["AuthToken"]);
                    model.PhoneNumber = Convert.ToString(ds.Tables[0].Rows[0]["PhoneNumber"]);
                    model.SandboxMode = Convert.ToBoolean(ds.Tables[0].Rows[0]["SandboxMode"]);
                    model.StatusCallbackUrl = Convert.ToString(ds.Tables[0].Rows[0]["StatusCallbackUrl"]);
                }
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:GetWhatsappConfig : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<int> SaveWhatsappConfig(int loginUserId, WhatsappConfigModel model)
        {
            try
            {
                int result = await _SetupRepo.SaveWhatsappConfig(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:SaveWhatsappConfig : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion


        #region Payment Method Category


        public async Task<PaymentMethodCategoryModel> GetPaymentMethodCategoryById(long paymentMethodCategoryId)
        {
            try
            {
                PaymentMethodCategoryModel model = new PaymentMethodCategoryModel();
                DataSet ds = await _SetupRepo.GetPaymentMethodCategory(paymentMethodCategoryId);
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.PaymentMethodCategoryId = Convert.ToInt64(ds.Tables[0].Rows[0]["PaymentMethodCategoryId"]);
                    model.CategoryName = Convert.ToString(ds.Tables[0].Rows[0]["CategoryName"]);
                    model.IsActive = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsActive"]);
                }
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:GetPaymentMethodCategoryById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
 

        public async Task<DataSet> GetPaymentMethodCategory()
		{
			try
			{
				DataSet ds = await _SetupRepo.GetPaymentMethodCategory(0);
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:SetupService:GetPaymentMethodCategory : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}


		public async Task<int> SavePaymentMethodCategory(PaymentMethodCategoryModel model)
		{
			try
			{
				int result = await _SetupRepo.SavePaymentMethodCategory(model);
				return result;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:SetupService:SavePaymentMethodCategory : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}

        #endregion

        #region Payment Method


        public async Task<PaymentMethodModel> GetPaymentMethodById(long paymentMethodId)
        {
            try
            {
                PaymentMethodModel model = new PaymentMethodModel();
                DataSet ds = await _SetupRepo.GetPaymentMethod(paymentMethodId);
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.PaymentMethodId = Convert.ToInt64(ds.Tables[0].Rows[0]["PaymentMethodId"]);
                    model.PaymentMethodCategoryId = Convert.ToInt64(ds.Tables[0].Rows[0]["PaymentMethodCategoryId"]);
                    model.PaymentMethodName = Convert.ToString(ds.Tables[0].Rows[0]["PaymentMethodName"]);
                    model.DebitAccount = Convert.ToString(ds.Tables[0].Rows[0]["DebitAccount"]);
                    model.CreditAccount = Convert.ToString(ds.Tables[0].Rows[0]["CreditAccount"]);
                    model.IsActive = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsActive"]);
                }
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:GetPaymentMethodById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }


        public async Task<DataSet> GetPaymentMethod()
		{
			try
			{
				DataSet ds = await _SetupRepo.GetPaymentMethod(0);
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:SetupService:GetPaymentMethod : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}

		public async Task<int> SavePaymentMethod(PaymentMethodModel model)
		{
			try
			{
				int result = await _SetupRepo.SavePaymentMethod(model);
				return result;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:SetupService:SavePaymentMethod : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}


        public async Task<int> DeletePaymentMethod(long paymentMethodId)
        {
            try
            {
                int result = await _SetupRepo.DeletePaymentMethod(paymentMethodId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SetupService:DeletePaymentMethod : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion

    }
}
