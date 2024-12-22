using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using School.Database.WebRepos;
using School.Models.WebModels;
using School.Models.WebModels.ParentModels;
using School.Models.WebModels.StudentModels;
using School.Services.WebServices.Services;
using System.Data;

namespace School.Services.WebServices.Implementation
{
	public class ParentService : IParentService
    {
        ParentRepo _ParentRepo;
        private readonly ILogger<ParentService> _logger;
        public ParentService(IOptions<AppSettingConfig> appSettingConfig, ILogger<ParentService> logger)
        {
            _ParentRepo = new ParentRepo(appSettingConfig);
            _logger = logger;
        }

        #region Parent
        public async Task<ParentModel> GetParentById(int parentId)
        {
            try
            {
                ParentModel model = new ParentModel();
                DataSet ds = await _ParentRepo.GetParents(parentId, new ParentFilterModel());
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.ParentId = Convert.ToInt32(ds.Tables[0].Rows[0]["ParentId"]);
                    model.ParentCode = Convert.ToString(ds.Tables[0].Rows[0]["ParentCode"]);
                    model.ParentImage = Convert.ToString(ds.Tables[0].Rows[0]["ParentImage"]);
                    model.FatherName = Convert.ToString(ds.Tables[0].Rows[0]["FatherName"]);
                    model.FatherArabicName = Convert.ToString(ds.Tables[0].Rows[0]["FatherArabicName"]);
                    model.FatherNationalityId = Convert.ToInt32(ds.Tables[0].Rows[0]["FatherNationalityId"]);
                    model.FatherMobile = Convert.ToString(ds.Tables[0].Rows[0]["FatherMobile"]);
                    model.FatherEmail = Convert.ToString(ds.Tables[0].Rows[0]["FatherEmail"]);
                    model.FatherIqamaNo = Convert.ToString(ds.Tables[0].Rows[0]["FatherIqamaNo"]);
                    model.FatherCountryName = Convert.ToString(ds.Tables[0].Rows[0]["FatherCountryName"]);
                    model.IsFatherStaff = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsFatherStaff"]);
                    model.MotherName = Convert.ToString(ds.Tables[0].Rows[0]["MotherName"]);
                    model.MotherArabicName = Convert.ToString(ds.Tables[0].Rows[0]["MotherArabicName"]);
                    model.MotherNationalityId = Convert.ToInt32(ds.Tables[0].Rows[0]["MotherNationalityId"]);
                    model.MotherMobile = Convert.ToString(ds.Tables[0].Rows[0]["MotherMobile"]);
                    model.MotherEmail = Convert.ToString(ds.Tables[0].Rows[0]["MotherEmail"]);
                    model.MotherIqamaNo = Convert.ToString(ds.Tables[0].Rows[0]["MotherIqamaNo"]);
                    model.MotherCountryName = Convert.ToString(ds.Tables[0].Rows[0]["MotherCountryName"]);
                    model.IsMotherStaff = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsMotherStaff"]);
                    model.IsActive = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsActive"]);
                    if (model.ParentId > 0 && ds.Tables.Count > 1 && ds.Tables[1].Rows.Count > 0)
                    {
                        List<StudentModel> StudentModelList = new List<StudentModel>();
                        foreach (DataRow dr in ds.Tables[1].Rows)
                        {
                            StudentModel studentModel = new StudentModel();
                            studentModel.StudentId = Convert.ToInt32(dr["StudentId"]);
                            studentModel.StudentCode = Convert.ToString(dr["StudentCode"]);
                            studentModel.StudentImage = Convert.ToString(dr["StudentImage"]);
                            studentModel.ParentId = Convert.ToInt32(dr["ParentId"]);
                            studentModel.ParentCode = Convert.ToString(dr["ParentCode"]);
                            studentModel.StudentName = Convert.ToString(dr["StudentName"]);
                            studentModel.StudentArabicName = Convert.ToString(dr["StudentArabicName"]);
                            studentModel.StudentEmail = Convert.ToString(dr["StudentEmail"]);
                            studentModel.DOB = Convert.ToString(dr["DOB"]);
                            studentModel.IqamaNo = Convert.ToString(dr["IqamaNo"]);
                            studentModel.NationalityId = Convert.ToInt32(dr["NationalityId"]);
                            studentModel.CountryName = Convert.ToString(dr["CountryName"]);
                            studentModel.GenderId = Convert.ToInt32(dr["GenderId"]);
                            studentModel.GenderTypeName = Convert.ToString(dr["GenderTypeName"]);
                            studentModel.AdmissionDate = Convert.ToString(dr["AdmissionDate"]);
                            studentModel.CostCenterId = Convert.ToInt32(dr["CostCenterId"]);
                            studentModel.CostCenterName = Convert.ToString(dr["CostCenterName"]);
                            studentModel.GradeId = Convert.ToInt32(dr["GradeId"]);
                            studentModel.GradeName = Convert.ToString(dr["GradeName"]);
                            studentModel.SectionId = Convert.ToInt32(dr["SectionId"]);
                            studentModel.SectionName = Convert.ToString(dr["SectionName"]);
                            studentModel.PassportNo = Convert.ToString(dr["PassportNo"]);
                            studentModel.PassportExpiry = Convert.ToString(dr["PassportExpiry"]);
                            studentModel.Mobile = Convert.ToString(dr["Mobile"]);
                            studentModel.StudentAddress = Convert.ToString(dr["StudentAddress"]);
                            studentModel.StudentStatusId = Convert.ToInt32(dr["StudentStatusId"]);
                            studentModel.StatusName = Convert.ToString(dr["StatusName"]);
                            studentModel.Fees = Convert.ToDecimal(dr["Fees"]);
                            studentModel.IsGPIntegration = Convert.ToBoolean(dr["IsGPIntegration"]);
                            studentModel.WithdrawDate = Convert.ToString(dr["WithdrawDate"]);
                            studentModel.WithdrawAt = Convert.ToInt32(dr["WithdrawAt"]);
                            studentModel.WithdrawAtTermName = Convert.ToString(dr["WithdrawAtTermName"]);
                            studentModel.WithdrawYear = Convert.ToString(dr["WithdrawYear"]);
                            studentModel.TermId = Convert.ToInt32(dr["TermId"]);
                            studentModel.TermName = Convert.ToString(dr["TermName"]);
                            studentModel.AdmissionYear = Convert.ToString(dr["AdmissionYear"]);
                            studentModel.PrinceAccount = Convert.ToBoolean(dr["PrinceAccount"]);
                            studentModel.IsActive = Convert.ToBoolean(dr["IsActive"]);
                            StudentModelList.Add(studentModel);
                        }
                        model.StudentModelList = StudentModelList;

                    }
                    if (model.ParentId > 0 && ds.Tables.Count > 2 && ds.Tables[2].Rows.Count > 0)
                    {
                        ParentAccountModel accountModel = new ParentAccountModel();
                        accountModel.ParentId = Convert.ToInt32(ds.Tables[2].Rows[0]["ParentId"]);
                        accountModel.ReceivableAccount = Convert.ToString(ds.Tables[2].Rows[0]["ReceivableAccount"]);
                        accountModel.AdvanceAccount = Convert.ToString(ds.Tables[2].Rows[0]["AdvanceAccount"]);
                        model.AccountModel = accountModel;
                    }
                   
                }
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:ParentService:GetParentById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<DataSet> GetParents(ParentFilterModel filterMode)
        {
            try
            {
                DataSet ds = await _ParentRepo.GetParents(0, filterMode);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:ParentService:GetParents : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<int> SaveParent(int loginUserId, ParentModel model)
        {
            try
            {
                int result = await _ParentRepo.SaveParent(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:ParentService:SaveParent : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> DeleteParent(int loginUserId, int parentId)
        {
            try
            {
                int result = await _ParentRepo.DeleteParent(loginUserId, parentId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:ParentService:DeleteParent : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<int> UpdateParentProfilePicture(int loginUserId, int parentId, string ImgPath)
        {
            try
            {
                int result = await _ParentRepo.UpdateParentImage(loginUserId, parentId, ImgPath);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:ParentService:UpdateParentProfilePicture : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<int> UpdateAccount(int loginUserId, ParentAccountModel model)
        {
            try
            {
                int result = await _ParentRepo.UpdateAccount(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:ParentService:UpdateAccount : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<DataSet> GetStudentFeeStatement(int academicYearId, int parentId, int studentId)
        {
            try
            {
                DataSet ds = await _ParentRepo.GetStudentFeeStatement(academicYearId, parentId, studentId);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:ParentService:GetStudentFeeStatement : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        #endregion
    }
}
