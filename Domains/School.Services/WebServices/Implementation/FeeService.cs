using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using School.Database.WebRepos;
using School.Models.WebModels;
using School.Models.WebModels.FeeModels;
using School.Models.WebModels.FeetypeModels;
using School.Models.WebModels.PaymentPlanModels;
using School.Models.WebModels.SchoolTermAcademicModels;
using School.Services.WebServices.Services;
using System.Data;

namespace School.Services.WebServices.Implementation
{
	public class FeeService : IFeeService
    {
        FeeRepo _FeeRepo;
        private readonly ILogger<ReportService> _logger;

        public FeeService(IOptions<AppSettingConfig> appSettingConfig, ILogger<ReportService> logger)
        {
            _FeeRepo = new FeeRepo(appSettingConfig);
            _logger = logger;
        }

        #region Fee Type
        public async Task<int> DeleteFeeType(int loginUserId, long feeTypeId)
        {
            try
            {
                int result = await _FeeRepo.DeleteFeeType(loginUserId, feeTypeId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:FeeService:DeleteFeeTypeId : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<FeeTypeModel> GetFeeTypeById(long feeTypeId)
        {
            try
            {
                FeeTypeModel model = new FeeTypeModel();
                DataSet ds = await _FeeRepo.GetFeeType(feeTypeId);
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.FeeTypeId = Convert.ToInt32(ds.Tables[0].Rows[0]["FeeTypeId"]);
                    model.FeeTypeName = Convert.ToString(ds.Tables[0].Rows[0]["FeeTypeName"]);
                    model.IsPrimary = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsPrimary"]);
                    model.IsGradeWise = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsGradeWise"]);
                    model.IsTermPlan = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsTermPlan"]);
                    model.IsPaymentPlan = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsPaymentPlan"]);
                    model.DebitAccount = Convert.ToString(ds.Tables[0].Rows[0]["DebitAccount"]);
                    model.CreditAccount = Convert.ToString(ds.Tables[0].Rows[0]["CreditAccount"]);
                }
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:FeeService:GetFeeTypeById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<DataSet> GetFeeType()
        {
            try
            {
                DataSet ds = await _FeeRepo.GetFeeType(0);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:FeeService:GetFeeType : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> SaveFeeType(int loginUserId, FeeTypeModel model)
        {
            try
            {
                int result = await _FeeRepo.SaveFeeType(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:FeeService:SaveFeeType : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion

        #region Fee Type Detail
        public async Task<int> DeleteFeeTypeDetail(int loginUserId, long feeTypeId)
        {
            try
            {
                int result = await _FeeRepo.DeleteFeeTypeDetail(loginUserId, feeTypeId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:FeeService:DeleteFeeTypeDetail : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<FeeTermDetailModel> GetFeeTypeDetailById(long feeTypeId, long feeTypeDetailId)
        {
            try
            {
                FeeTermDetailModel model = new FeeTermDetailModel();
                DataSet ds = await _FeeRepo.GetFeeTypeDetails(feeTypeId, feeTypeDetailId);
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.FeeTypeId = Convert.ToInt32(ds.Tables[0].Rows[0]["FeeTypeId"]);
                    model.FeeTypeName = Convert.ToString(ds.Tables[0].Rows[0]["FeeTypeName"]);

                    model.IsTermPlan = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsTermPlan"]);
                    model.IsPaymentPlan = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsPaymentPlan"]);
                    model.IsGradeWise = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsGradeWise"]);

                    model.FeeTypeDetailId = Convert.ToInt32(ds.Tables[0].Rows[0]["FeeTypeDetailId"]);
                    model.AcademicYearId = Convert.ToInt32(ds.Tables[0].Rows[0]["AcademicYearId"]);
                    model.TermFeeAmount = Convert.ToDecimal(ds.Tables[0].Rows[0]["TermFeeAmount"]);
                    model.StaffFeeAmount = Convert.ToDecimal(ds.Tables[0].Rows[0]["StaffFeeAmount"]);
                    model.GradeId = Convert.ToInt32(ds.Tables[0].Rows[0]["GradeId"]);
                    model.GradeName = Convert.ToString(ds.Tables[0].Rows[0]["GradeName"]);
                    model.IsActive = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsActive"]);
                    model.AcademicYear = Convert.ToString(ds.Tables[0].Rows[0]["AcademicYear"]);
                    model.TotalTerm = Convert.ToInt32(ds.Tables[0].Rows[0]["TotalTerm"]);
                    model.TotalTerm = model.TotalTerm == 0 ? 1 : model.TotalTerm;
                }
                if (ds != null && ds.Tables.Count >= 2 && ds.Tables[1].Rows.Count > 0)
                {
                    for (int i = 0; i < ds.Tables[1].Rows.Count; i++)
                    {
                        SchoolTermAcademicModel schoolTermAcademicModel = new SchoolTermAcademicModel();
                        //SchoolTermAcademicId	SchoolAcademicId	StartDate	EndDate	
                        schoolTermAcademicModel.SchoolTermAcademicId = Convert.ToInt32(ds.Tables[1].Rows[i]["SchoolTermAcademicId"]);
                        schoolTermAcademicModel.SchoolAcademicId = Convert.ToInt32(ds.Tables[1].Rows[i]["SchoolAcademicId"]);

                        schoolTermAcademicModel.StartDate = Convert.ToString(ds.Tables[1].Rows[i]["StartDate"]);
                        schoolTermAcademicModel.EndDate = Convert.ToString(ds.Tables[1].Rows[i]["EndDate"]);

                        schoolTermAcademicModel.TermName = Convert.ToString(ds.Tables[1].Rows[i]["TermName"]);

                        //model.IsActive = Convert.ToBoolean(ds.Tables[1].Rows[i]["IsActive"]);

                        model.TermList.Add(schoolTermAcademicModel);
                    }

                }
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:FeeService:GetFeeTypeDetailById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<FeeTermDetailModel> GetFeeTermDetailById(long feeTypeId, long feeTypeDetailId)
        {
            try
            {
                FeeTermDetailModel model = new FeeTermDetailModel();
                DataSet ds = await _FeeRepo.GetFeeTypeDetails(feeTypeId, feeTypeDetailId);
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.FeeTypeId = Convert.ToInt32(ds.Tables[0].Rows[0]["FeeTypeId"]);
                    //model.FeeTypeName = Convert.ToString(ds.Tables[0].Rows[0]["FeeTypeName"]);
                    //model.IsTermPlan = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsTermPlan"]);
                    //model.IsPaymentPlan = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsPaymentPlan"]);
                }
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:FeeService:GetFeeTermDetailById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }


        public async Task<DataSet> GetFeeTypeDetails(long feeTypeId, long feeTypeDetailId)
        {
            try
            {
                DataSet ds = await _FeeRepo.GetFeeTypeDetails(feeTypeId, feeTypeDetailId);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:FeeService:GetFeeTypeDetails : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> SaveFeeTypeDetail(int loginUserId, FeeTermDetailSaveModel model)
        {
            try
            {
                int result = await _FeeRepo.SaveFeeTypeDetail(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:FeeService:SaveFeeTypeDetail : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        #endregion Fee Type Detail

        #region FeeStructure
        public async Task<DataSet> GetFeeStructure(string academicYear)
        {
            try
            {
                DataSet ds = await _FeeRepo.GetFeeStructure(academicYear);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:FeeService:GetFeeStructure : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> SaveFeeStructure(int loginUserId, List<FeeStructureModel> feeStructureModelList, List<GradeWiseFeeStructureModel> gradeWiseFeeStructureModelList)
        {
            try
            {
                int res = await _FeeRepo.SaveFeeStructure(loginUserId, feeStructureModelList, gradeWiseFeeStructureModelList);
                return res;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:FeeService:SaveFeeStructure : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion

        #region Fee Plan        
        public async Task<DataSet> GetFeePlanWithoutGradewise(long feeTypeId)
        {
            try
            {
                DataSet ds = await _FeeRepo.GetFeePlanWithoutGradewise(feeTypeId, 0);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:FeeService:GetFeePlanWithoutGradewise : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<DataSet> GetFeePlanWithGradewise(long feeTypeId, string academicYear)
        {
            try
            {
                DataSet ds = await _FeeRepo.GetFeePlanWithGradewise(feeTypeId, academicYear);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:FeeService:GetFeePlanWithGradewise : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<FeePlanModel> GetFeePlanWithoutGradewiseById(long feeTypeId, long feeStructureId)
        {
            try
            {
                FeePlanModel model = new FeePlanModel();
                DataSet ds = await _FeeRepo.GetFeePlanWithoutGradewise(feeTypeId, feeStructureId);
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.FeeTypeId = Convert.ToInt32(ds.Tables[0].Rows[0]["FeeTypeId"]);
                    model.FeeTypeName = Convert.ToString(ds.Tables[0].Rows[0]["FeeTypeName"]);
                    model.IsGradeWise = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsGradeWise"]);
                    model.FeeStructureId = Convert.ToInt32(ds.Tables[0].Rows[0]["FeeStructureId"]);
                    model.AcademicYear = Convert.ToString(ds.Tables[0].Rows[0]["AcademicYear"]);
                    model.FeeAmount = Convert.ToDecimal(ds.Tables[0].Rows[0]["FeeAmount"]);
                }
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:FeeService:GetFeePlanWithoutGradewiseById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> DeleteFeePlanWithoutGradewise(int loginUserId, long feeStructureId)
        {
            try
            {
                int result = await _FeeRepo.DeleteFeePlanWithoutGradewise(loginUserId, feeStructureId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:FeeService:DeleteFeePlanWithoutGradewise : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> SaveFeePlanWithoutGradewise(int loginUserId, FeePlanModel model)
        {
            try
            {
                int result = await _FeeRepo.SaveFeePlanWithoutGradewise(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:FeeService:SaveFeePlanWithoutGradewise : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> SaveFeePlanWithoutGradewise(int loginUserId, List<GradeWiseFeeStructureModel> gradeWiseFeeStructureModelList)
        {
            try
            {
                int res = await _FeeRepo.SaveFeePlanWithoutGradewise(loginUserId, gradeWiseFeeStructureModelList);
                return res;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:FeeService:SaveFeePlanWithoutGradewise : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion

        #region Fee Payment Plan
        public async Task<DataSet> GetFeePaymentPlan(long feeTypeDetailId)
        {
            try
            {
                DataSet ds = await _FeeRepo.GetFeePaymentPlan(feeTypeDetailId,0);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:FeeService:GetFeePaymentPlan : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<int> SaveFeePaymentPlan(int loginUserId, PaymentPlanModel model)
        {
            try
            {
                int result = await _FeeRepo.SaveFeePaymentPlan(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:FeeService:SaveFeePaymentPlan : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<int> DeleteFeePaymentPlan(int loginUserId, long feePaymentPlanId)
        {
            try
            {
                int result = await _FeeRepo.DeleteFeePaymentPlan(loginUserId, feePaymentPlanId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:FeeService:DeleteFeePaymentPlan : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<PaymentPlanModel> GetFeePaymentPlanById(long feeTypeDetailId, long feePaymentPlanId)
        {
            try
            {
                PaymentPlanModel model = new PaymentPlanModel();
                DataSet ds = await _FeeRepo.GetFeePaymentPlan(feeTypeDetailId, feePaymentPlanId);
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.FeePaymentPlanId = Convert.ToInt32(ds.Tables[0].Rows[0]["FeePaymentPlanId"]);
                    model.FeeTypeDetailId = Convert.ToInt32(ds.Tables[0].Rows[0]["FeeTypeDetailId"]);
                    model.PaymentPlanAmount = Convert.ToDecimal(ds.Tables[0].Rows[0]["PaymentPlanAmount"]);
                    model.DueDate = Convert.ToDateTime(ds.Tables[0].Rows[0]["DueDate"]);
                }
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:FeeService:GetFeePaymentPlanById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion
    }
}
