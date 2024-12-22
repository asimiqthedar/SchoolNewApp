using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using School.Database.WebRepos;
using School.Models.WebModels;
using School.Models.WebModels.BranchModels;
using School.Models.WebModels.ContactInformationModels;
using School.Models.WebModels.SchoolAccountInfoModels;
using School.Models.WebModels.SchoolModels;
using School.Services.WebServices.Services;
using System.Data;

namespace School.Services.WebServices.Implementation
{
	public class SchoolService : ISchoolService
    {
        SchoolRepo _SchoolRepo;
        private readonly ILogger<SchoolService> _logger;
        public SchoolService(IOptions<AppSettingConfig> appSettingConfig, ILogger<SchoolService> logger)
        {
            _SchoolRepo = new SchoolRepo(appSettingConfig);
            _logger = logger;
        }

        #region School
        public async Task<int> DeleteSchool(int loginUserId, int schoolId)
        {
            try
            {
                int result = await _SchoolRepo.DeleteSchool(loginUserId, schoolId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:DeleteSchool : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<SchoolModel> GetSchoolById(int schoolId)
        {
            try
            {
                SchoolModel model = new SchoolModel();
                DataSet ds = await _SchoolRepo.GetSchool(schoolId, new SchoolFilterModel());
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.SchoolId = Convert.ToInt32(ds.Tables[0].Rows[0]["SchoolId"]);
                    model.SchoolNameEnglish = Convert.ToString(ds.Tables[0].Rows[0]["SchoolNameEnglish"]);
                    model.SchoolNameArabic = Convert.ToString(ds.Tables[0].Rows[0]["SchoolNameArabic"]);
                    model.BranchId = Convert.ToInt32(ds.Tables[0].Rows[0]["BranchId"]);
                    model.BranchName = Convert.ToString(ds.Tables[0].Rows[0]["BranchName"]);
                    model.CountryId = Convert.ToInt32(ds.Tables[0].Rows[0]["CountryId"]);
                    model.CountryName = Convert.ToString(ds.Tables[0].Rows[0]["CountryName"]);
                    model.City = Convert.ToString(ds.Tables[0].Rows[0]["City"]);
                    model.Address = Convert.ToString(ds.Tables[0].Rows[0]["Address"]);
                    model.Telephone = Convert.ToString(ds.Tables[0].Rows[0]["Telephone"]);
                    model.SchoolEmail = Convert.ToString(ds.Tables[0].Rows[0]["SchoolEmail"]);
                    model.WebsiteUrl = Convert.ToString(ds.Tables[0].Rows[0]["WebsiteUrl"]);
                    model.VatNo = Convert.ToString(ds.Tables[0].Rows[0]["VatNo"]);
                    model.Logo = Convert.ToString(ds.Tables[0].Rows[0]["Logo"]);
                    model.IsActive = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsActive"]);
                }
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:GetSchoolById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<DataSet> GetSchool(SchoolFilterModel filterModel)
        {
            try
            {
                DataSet ds = await _SchoolRepo.GetSchool(0, filterModel);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:GetSchool : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<int> SaveSchool(int loginUserId, SchoolModel model)
        {
            try
            {
                int result = await _SchoolRepo.SaveSchool(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:SaveSchool : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> UpdateLogoPicture(int loginUserId, int schoolId, string ImgPath, string logoName)
        {
            try
            {
                int result = await _SchoolRepo.UpdateLogoImage(loginUserId, schoolId, ImgPath, logoName);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:UpdateLogoPicture : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<DataSet> GetSchoolLogo(int schoolId)
        {
            try
            {
                DataSet ds = await _SchoolRepo.GetSchoolLogo(schoolId);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:GetSchoolLogo : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> DeleteSchoolLogo(int schoolLogoId)
        {
            try
            {
                int result = await _SchoolRepo.DeleteSchoolLogo(schoolLogoId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:DeleteSchoolLogo : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion

        #region Branch
        public async Task<int> DeleteBranch(int loginUserId, int branchId)
        {
            try
            {
                int result = await _SchoolRepo.DeleteBranch(loginUserId, branchId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:DeleteBranch : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<BranchModel> GetBranchById(int branchId)
        {
            try
            {
                BranchModel model = new BranchModel();
                DataSet ds = await _SchoolRepo.GetBranch(branchId, new BranchFilterModel());
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.BranchId = Convert.ToInt32(ds.Tables[0].Rows[0]["BranchId"]);
                    model.BranchName = Convert.ToString(ds.Tables[0].Rows[0]["BranchName"]);
                    //model.City = Convert.ToString(ds.Tables[0].Rows[0]["City"]);
                    //model.CountryId = Convert.ToInt32(ds.Tables[0].Rows[0]["CountryId"]);
                    //model.CountryName = Convert.ToString(ds.Tables[0].Rows[0]["CountryName"]);
                    //model.Address = Convert.ToString(ds.Tables[0].Rows[0]["Address"]);
                    //model.Telephone = Convert.ToString(ds.Tables[0].Rows[0]["Telephone"]);
                    //model.BranchEmail = Convert.ToString(ds.Tables[0].Rows[0]["BranchEmail"]);
                    //model.VatNo = Convert.ToString(ds.Tables[0].Rows[0]["VatNo"]);
                    model.IsActive = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsActive"]);
                }
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:GetBranchById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<DataSet> GetBranch(BranchFilterModel filterModel)
        {
            try
            {
                DataSet ds = await _SchoolRepo.GetBranch(0, filterModel);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:GetBranch : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<int> SaveBranch(int loginUserId, BranchModel model)
        {
            try
            {
                int result = await _SchoolRepo.SaveBranch(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:SaveBranch : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion

        #region Contact Information
        public async Task<int> DeleteContactInformation(int loginUserId, int contactId)
        {
            try
            {
                int result = await _SchoolRepo.DeleteContactInformation(loginUserId, contactId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:DeleteContactInformation : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<ContactInformationModel> GetContactInformationById(int schoolId, int contactId)
        {
            try
            {
                ContactInformationModel model = new ContactInformationModel();
                DataSet ds = await _SchoolRepo.GetContactInfomation(schoolId, contactId, new ContactInformationFilterModel());
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.ContactId = Convert.ToInt32(ds.Tables[0].Rows[0]["ContactId"]);
                    model.SchoolId = Convert.ToInt32(ds.Tables[0].Rows[0]["SchoolId"]);
                    model.ContactPerson = Convert.ToString(ds.Tables[0].Rows[0]["ContactPerson"]);
                    model.ContactPosition = Convert.ToString(ds.Tables[0].Rows[0]["ContactPosition"]);
                    model.ContactTelephone = Convert.ToString(ds.Tables[0].Rows[0]["ContactTelephone"]);
                    model.ContactEmail = Convert.ToString(ds.Tables[0].Rows[0]["ContactEmail"]);
                    model.IsActive = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsActive"]);
                }
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:GetContactInformationById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<DataSet> GetContactInformation(int schoolId, ContactInformationFilterModel filterModel)
        {
            try
            {
                DataSet ds = await _SchoolRepo.GetContactInfomation(schoolId, 0, filterModel);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:GetContactInformation : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<int> SaveContactInformation(int loginUserId, ContactInformationModel model)
        {
            try
            {
                int result = await _SchoolRepo.SaveContactInformation(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:SaveContactInformation : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion

        //#region Academic Year
        //public async Task<int> DeleteSchoolAcademic(int loginUserId, int schoolAcademicId)
        //{
        //    try
        //    {
        //        int result = await _SchoolRepo.DeleteSchoolAcademic(loginUserId, schoolAcademicId);
        //        return result;
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}

        //public async Task<SchoolAcademicModel> GetSchoolAcademicById(int schoolId, int schoolAcademicId)
        //{
        //    try
        //    {
        //        SchoolAcademicModel model = new SchoolAcademicModel();
        //        DataSet ds = await _SchoolRepo.GetSchoolAcademic(schoolId, schoolAcademicId);
        //        if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
        //        {
        //            model.SchoolAcademicId = Convert.ToInt32(ds.Tables[0].Rows[0]["SchoolAcademicId"]);
        //            //model.SchoolId = Convert.ToInt32(ds.Tables[0].Rows[0]["SchoolId"]);
        //            model.AcademicYear = Convert.ToString(ds.Tables[0].Rows[0]["AcademicYear"]);
        //            model.PeriodFrom = Convert.ToString(ds.Tables[0].Rows[0]["PeriodFrom"]);
        //            model.PeriodTo = Convert.ToString(ds.Tables[0].Rows[0]["PeriodTo"]);
        //            model.IsActive = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsActive"]);
        //        }
        //        return model;
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}

        //public async Task<DataSet> GetSchoolAcademic(int schoolId)
        //{
        //    try
        //    {
        //        DataSet ds = await _SchoolRepo.GetSchoolAcademic(schoolId, 0);
        //        return ds;
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}

        //public async Task<int> SaveSchoolAcademic(int loginUserId, SchoolAcademicModel model)
        //{
        //    try
        //    {
        //        int result = await _SchoolRepo.SaveSchoolAcademic(loginUserId, model);
        //        return result;
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}
        //#endregion

        //#region Academic Term
        //public async Task<int> DeleteSchoolTermAcademic(int loginUserId, int schoolTermAcademicId)
        //{
        //    try
        //    {
        //        int result = await _SchoolRepo.DeleteSchoolTermAcademic(loginUserId, schoolTermAcademicId);
        //        return result;
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}

        //public async Task<SchoolTermAcademicModel> GetSchoolTermAcademicById(int schoolId, int schoolTermAcademicId)
        //{
        //    try
        //    {
        //        SchoolTermAcademicModel model = new SchoolTermAcademicModel();
        //        DataSet ds = await _SchoolRepo.GetSchoolTermAcademic(schoolId, schoolTermAcademicId);
        //        if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
        //        {
        //            model.SchoolTermAcademicId = Convert.ToInt32(ds.Tables[0].Rows[0]["SchoolTermAcademicId"]);
        //            model.SchoolAcademicId = Convert.ToInt32(ds.Tables[0].Rows[0]["SchoolAcademicId"]);
        //            model.TermId = Convert.ToInt32(ds.Tables[0].Rows[0]["TermId"]);
        //            model.SchoolId = Convert.ToInt32(ds.Tables[0].Rows[0]["SchoolId"]);
        //            model.AcademicYear = Convert.ToString(ds.Tables[0].Rows[0]["AcademicYear"]);
        //            model.TermName = Convert.ToString(ds.Tables[0].Rows[0]["TermName"]);
        //            model.StartDate = Convert.ToString(ds.Tables[0].Rows[0]["StartDate"]);
        //            model.EndDate = Convert.ToString(ds.Tables[0].Rows[0]["EndDate"]);
        //            model.IsActive = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsActive"]);
        //        }
        //        return model;
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}

        //public async Task<DataSet> GetSchoolTermAcademic(int schoolId)
        //{
        //    try
        //    {
        //        DataSet ds = await _SchoolRepo.GetSchoolTermAcademic(schoolId, 0);
        //        return ds;
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}

        //public async Task<int> SaveSchoolTermAcademic(int loginUserId, SchoolTermAcademicModel model)
        //{
        //    try
        //    {
        //        int result = await _SchoolRepo.SaveSchoolTermAcademic(loginUserId, model);
        //        return result;
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //}
        //#endregion

        #region School Account Info
        public async Task<int> DeleteSchoolAccountInfo(int loginUserId, int schoolAccountIId)
        {
            try
            {
                int result = await _SchoolRepo.DeleteSchoolAccountInfo(loginUserId, schoolAccountIId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:DeleteSchoolAccountInfo : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<SchoolAccountInfoModel> GetSchoolAccountInfoById(int schoolId, int schoolAccountIId)
        {
            try
            {
                SchoolAccountInfoModel model = new SchoolAccountInfoModel();
                DataSet ds = await _SchoolRepo.GetSchoolAccountInfo(schoolId, schoolAccountIId);
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.SchoolAccountIId = Convert.ToInt32(ds.Tables[0].Rows[0]["SchoolAccountIId"]);
                    model.SchoolId = Convert.ToInt32(ds.Tables[0].Rows[0]["SchoolId"]);
                    model.ReceivableAccount = Convert.ToString(ds.Tables[0].Rows[0]["ReceivableAccount"]);
                    model.AdvanceAccount = Convert.ToString(ds.Tables[0].Rows[0]["AdvanceAccount"]);
                    model.CodeDescription = Convert.ToString(ds.Tables[0].Rows[0]["CodeDescription"]);
                }
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:GetSchoolAccountInfoById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<DataSet> GetSchoolAccountInfo(int schoolId)
        {
            try
            {
                DataSet ds = await _SchoolRepo.GetSchoolAccountInfo(schoolId, 0);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:GetSchoolAccountInfo : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<int> SaveSchoolAccountInfo(int loginUserId, SchoolAccountInfoModel model)
        {
            try
            {
                int result = await _SchoolRepo.SaveSchoolAccountInfo(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:SaveSchoolAccountInfo : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion

        #region Generate Fee
        public async Task<DataSet> GetGenerateFee()
        {
            try
            {
                DataSet ds = await _SchoolRepo.GetGenerateFee(0);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:GetGenerateFee : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;

            }
        }
        public async Task<int> SaveGenerateFee(int loginUserId, GenerateFeeModel model)
        {
            try
            {
                int result = await _SchoolRepo.SaveGenerateFee(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:SaveGenerateFee : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> UpdateGenerateFee(int loginUserId, int feeGenerateId, int actionId)
        {
            try
            {
                int result = await _SchoolRepo.UpdateGenerateFee(loginUserId, feeGenerateId, actionId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:UpdateGenerateFee : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<DataSet> GetGenerateFeeById(int feeGenerateId)
        {
            try
            {
                DataSet ds = await _SchoolRepo.GetGenerateFee(feeGenerateId);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:GetGenerateFeeById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion

        #region Generate Sibling Discount
        public async Task<DataSet> GetGenerateSiblingDiscount()
        {
            try
            {
                DataSet ds = await _SchoolRepo.GetGenerateSiblingDiscount(0);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:GetGenerateSiblingDiscount : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;

            }
        }
        public async Task<int> SaveGenerateSiblingDiscount(int loginUserId, GenerateSiblingDiscountModel model)
        {
            try
            {
                int result = await _SchoolRepo.SaveGenerateSiblingDiscount(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:SaveGenerateSiblingDiscount : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> UpdateGenerateSiblingDiscount(int loginUserId, int siblingDiscountId, int actionId)
        {
            try
            {
                int result = await _SchoolRepo.UpdateGenerateSiblingDiscount(loginUserId, siblingDiscountId, actionId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:UpdateGenerateFee : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<DataSet> GetGenerateSiblingDiscountById(int siblingDiscountId)
        {
            try
            {
                DataSet ds = await _SchoolRepo.GetGenerateSiblingDiscount(siblingDiscountId);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:GetGenerateSiblingDiscountById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion
        public async Task<DataSet> GetSiblingDiscountDetail(int academicYearId)
        {
            try
            {
                DataSet ds = await _SchoolRepo.GetSiblingDiscountDetail(academicYearId);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:GetSiblingDiscountDetail : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> CancleMultiSiblingDiscount(int loginUserId, string studentSiblingDiscountDetailIds)
        {
            try
            {
                int result = await _SchoolRepo.CancleMultiSiblingDiscount(loginUserId, studentSiblingDiscountDetailIds);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:SchoolService:CancleMultiSiblingDiscount : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
    }
}
