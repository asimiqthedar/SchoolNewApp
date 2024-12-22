using School.Models.WebModels.FeeModels;
using School.Models.WebModels.FeetypeModels;
using School.Models.WebModels.PaymentPlanModels;
using System.Data;

namespace School.Services.WebServices.Services
{
	public interface IFeeService
    {
        #region FeeStructure
        Task<DataSet> GetFeeStructure(string academicYear);
        Task<int> SaveFeeStructure(int loginUserId, List<FeeStructureModel> feeStructureModelList, List<GradeWiseFeeStructureModel> gradeWiseFeeStructureModelList);
        #endregion

        #region Fee Type
        Task<DataSet> GetFeeType();
        Task<FeeTypeModel> GetFeeTypeById(long feeTypeId);
        Task<int> SaveFeeType(int loginUserId, FeeTypeModel model);
        Task<int> DeleteFeeType(int loginUserId, long feeTypeId);
        #endregion

        #region Fee Type Detail
        Task<DataSet> GetFeeTypeDetails(long feeTypeId, long feeTypeDetailId);
        Task<FeeTermDetailModel> GetFeeTypeDetailById(long feeTypeId, long feeTypeDetailId);
        Task<int> SaveFeeTypeDetail(int loginUserId, FeeTermDetailSaveModel model);
        Task<int> DeleteFeeTypeDetail(int loginUserId, long feeTypeId);
        #endregion

        #region Fee Plan
        Task<DataSet> GetFeePlanWithoutGradewise(long feeTypeId);
        Task<DataSet> GetFeePlanWithGradewise(long feeTypeId, string academicYear);
        Task<FeePlanModel> GetFeePlanWithoutGradewiseById(long feeTypeId, long feeStructureId);
        Task<int> SaveFeePlanWithoutGradewise(int loginUserId, FeePlanModel model);
        Task<int> DeleteFeePlanWithoutGradewise(int loginUserId, long feeStructureId);
        Task<int> SaveFeePlanWithoutGradewise(int loginUserId, List<GradeWiseFeeStructureModel> gradeWiseFeeStructureModelList);
        #endregion

        #region Fee Payment Plan
        Task<DataSet> GetFeePaymentPlan(long feeTypeDetailId);
        Task<int> SaveFeePaymentPlan(int loginUserId, PaymentPlanModel model);
        Task<int> DeleteFeePaymentPlan(int loginUserId, long feePaymentPlanId);
        Task<PaymentPlanModel> GetFeePaymentPlanById(long feeTypeDetailId, long feePaymentPlanId);
        #endregion
    }
}
