using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using School.Database.WebRepos;
using School.Models.WebModels;
using School.Models.WebModels.GradeModels;
using School.Models.WebModels.StudentModels;
using School.Services.WebServices.Services;
using System.Data;

namespace School.Services.WebServices.Implementation
{
	public class StudentService : IStudentService
	{
		StudentRepo _StudentRepo;
		private readonly ILogger<StudentService> _logger;
		public StudentService(IOptions<AppSettingConfig> appSettingConfig, ILogger<StudentService> logger)
		{
			_StudentRepo = new StudentRepo(appSettingConfig);
			_logger = logger;
		}




		public async Task<DataSet> GetStudentByIdDs(int studentId)
		{
			try
			{
				
				DataSet ds = await _StudentRepo.GetStudents(studentId, new StudentFilterModel());
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:StudentService:GetStudentById : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		#region Student
		public async Task<StudentModel> GetStudentById(int studentId)
		{
			try
			{
				StudentModel model = new StudentModel();
				DataSet ds = await _StudentRepo.GetStudents(studentId, new StudentFilterModel());
				if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
				{
					model.StudentId = Convert.ToInt32(ds.Tables[0].Rows[0]["StudentId"]);
					model.StudentCode = Convert.ToString(ds.Tables[0].Rows[0]["StudentCode"]);
					model.StudentImage = Convert.ToString(ds.Tables[0].Rows[0]["StudentImage"]);
					model.ParentId = Convert.ToInt32(ds.Tables[0].Rows[0]["ParentId"]);
					model.ParentCode = Convert.ToString(ds.Tables[0].Rows[0]["ParentCode"]);
					model.StudentName = Convert.ToString(ds.Tables[0].Rows[0]["StudentName"]);
					model.StudentArabicName = Convert.ToString(ds.Tables[0].Rows[0]["StudentArabicName"]);
					model.StudentEmail = Convert.ToString(ds.Tables[0].Rows[0]["StudentEmail"]);
					model.DOB = Convert.ToString(ds.Tables[0].Rows[0]["DOB"]);
					model.IqamaNo = Convert.ToString(ds.Tables[0].Rows[0]["IqamaNo"]);
					model.NationalityId = Convert.ToInt32(ds.Tables[0].Rows[0]["NationalityId"]);
					model.CountryName = Convert.ToString(ds.Tables[0].Rows[0]["CountryName"]);
					model.GenderId = Convert.ToInt32(ds.Tables[0].Rows[0]["GenderId"]);
					model.GenderTypeName = Convert.ToString(ds.Tables[0].Rows[0]["GenderTypeName"]);
					model.AdmissionDate = Convert.ToString(ds.Tables[0].Rows[0]["AdmissionDate"]);
					model.CostCenterId = Convert.ToInt32(ds.Tables[0].Rows[0]["CostCenterId"]);
					model.CostCenterName = Convert.ToString(ds.Tables[0].Rows[0]["CostCenterName"]);
					model.GradeId = Convert.ToInt32(ds.Tables[0].Rows[0]["GradeId"]);
					model.GradeName = Convert.ToString(ds.Tables[0].Rows[0]["GradeName"]);
					model.SectionId = Convert.ToInt32(ds.Tables[0].Rows[0]["SectionId"]);
					model.SectionName = Convert.ToString(ds.Tables[0].Rows[0]["SectionName"]);
					model.PassportNo = Convert.ToString(ds.Tables[0].Rows[0]["PassportNo"]);
					model.PassportExpiry = Convert.ToString(ds.Tables[0].Rows[0]["PassportExpiry"]);
					model.Mobile = Convert.ToString(ds.Tables[0].Rows[0]["Mobile"]);
					model.StudentAddress = Convert.ToString(ds.Tables[0].Rows[0]["StudentAddress"]);
					model.StudentStatusId = Convert.ToInt32(ds.Tables[0].Rows[0]["StudentStatusId"]);
					model.StatusName = Convert.ToString(ds.Tables[0].Rows[0]["StatusName"]);
					model.Fees = Convert.ToDecimal(ds.Tables[0].Rows[0]["Fees"]);
					model.IsGPIntegration = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsGPIntegration"]);
					model.WithdrawDate = Convert.ToString(ds.Tables[0].Rows[0]["WithdrawDate"]);
					model.WithdrawAt = Convert.ToInt32(ds.Tables[0].Rows[0]["WithdrawAt"]);
					model.WithdrawAtTermName = Convert.ToString(ds.Tables[0].Rows[0]["WithdrawAtTermName"]);
					model.WithdrawYear = Convert.ToString(ds.Tables[0].Rows[0]["WithdrawYear"]);
					model.TermId = Convert.ToInt32(ds.Tables[0].Rows[0]["TermId"]);
					model.TermName = Convert.ToString(ds.Tables[0].Rows[0]["TermName"]);
					model.AdmissionYear = Convert.ToString(ds.Tables[0].Rows[0]["AdmissionYear"]);
					model.PrinceAccount = Convert.ToBoolean(ds.Tables[0].Rows[0]["PrinceAccount"]);
					model.IsActive = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsActive"]);

					if (model.StudentId > 0 && ds.Tables.Count > 1 && ds.Tables[1].Rows.Count > 0)
					{
						StudentParentModel ParentModel = new StudentParentModel();
						ParentModel.ParentId = Convert.ToInt32(ds.Tables[1].Rows[0]["ParentId"]);
						ParentModel.ParentCode = Convert.ToString(ds.Tables[1].Rows[0]["ParentCode"]);
						ParentModel.ParentImage = Convert.ToString(ds.Tables[1].Rows[0]["ParentImage"]);
						ParentModel.FatherName = Convert.ToString(ds.Tables[1].Rows[0]["FatherName"]);
						ParentModel.FatherArabicName = Convert.ToString(ds.Tables[1].Rows[0]["FatherArabicName"]);
						ParentModel.FatherMobile = Convert.ToString(ds.Tables[1].Rows[0]["FatherMobile"]);
						ParentModel.FatherEmail = Convert.ToString(ds.Tables[1].Rows[0]["FatherEmail"]);
						ParentModel.IsFatherStaff = Convert.ToBoolean(ds.Tables[1].Rows[0]["IsFatherStaff"]);
						ParentModel.MotherName = Convert.ToString(ds.Tables[1].Rows[0]["MotherName"]);
						ParentModel.MotherArabicName = Convert.ToString(ds.Tables[1].Rows[0]["MotherArabicName"]);
						ParentModel.MotherMobile = Convert.ToString(ds.Tables[1].Rows[0]["MotherMobile"]);
						ParentModel.MotherEmail = Convert.ToString(ds.Tables[1].Rows[0]["MotherEmail"]);
						ParentModel.IsMotherStaff = Convert.ToBoolean(ds.Tables[1].Rows[0]["IsMotherStaff"]);
						model.ParentModel = ParentModel;
					}
					if (model.StudentId > 0 && ds.Tables.Count > 2 && ds.Tables[2].Rows.Count > 0)
					{
						List<StudentModel> StudentSiblingList = new List<StudentModel>();
						foreach (DataRow dr in ds.Tables[2].Rows)
						{
							StudentModel siblingModel = new StudentModel();
							siblingModel.StudentId = Convert.ToInt32(dr["StudentId"]);
							siblingModel.StudentCode = Convert.ToString(dr["StudentCode"]);
							siblingModel.StudentImage = Convert.ToString(dr["StudentImage"]);
							siblingModel.ParentId = Convert.ToInt32(dr["ParentId"]);
							siblingModel.ParentCode = Convert.ToString(dr["ParentCode"]);
							siblingModel.StudentName = Convert.ToString(dr["StudentName"]);
							siblingModel.StudentArabicName = Convert.ToString(dr["StudentArabicName"]);
							siblingModel.StudentEmail = Convert.ToString(dr["StudentEmail"]);
							siblingModel.DOB = Convert.ToString(dr["DOB"]);
							siblingModel.IqamaNo = Convert.ToString(dr["IqamaNo"]);
							siblingModel.NationalityId = Convert.ToInt32(dr["NationalityId"]);
							siblingModel.CountryName = Convert.ToString(dr["CountryName"]);
							siblingModel.GenderId = Convert.ToInt32(dr["GenderId"]);
							siblingModel.GenderTypeName = Convert.ToString(dr["GenderTypeName"]);
							siblingModel.AdmissionDate = Convert.ToString(dr["AdmissionDate"]);
							siblingModel.CostCenterId = Convert.ToInt32(dr["CostCenterId"]);
							siblingModel.CostCenterName = Convert.ToString(dr["CostCenterName"]);
							siblingModel.GradeId = Convert.ToInt32(dr["GradeId"]);
							siblingModel.GradeName = Convert.ToString(dr["GradeName"]);
							siblingModel.SectionId = Convert.ToInt32(dr["SectionId"]);
							siblingModel.SectionName = Convert.ToString(dr["SectionName"]);
							siblingModel.PassportNo = Convert.ToString(dr["PassportNo"]);
							siblingModel.PassportExpiry = Convert.ToString(dr["PassportExpiry"]);
							siblingModel.Mobile = Convert.ToString(dr["Mobile"]);
							siblingModel.StudentAddress = Convert.ToString(dr["StudentAddress"]);
							siblingModel.StudentStatusId = Convert.ToInt32(dr["StudentStatusId"]);
							siblingModel.StatusName = Convert.ToString(dr["StatusName"]);
							siblingModel.Fees = Convert.ToDecimal(dr["Fees"]);
							siblingModel.IsGPIntegration = Convert.ToBoolean(dr["IsGPIntegration"]);
							siblingModel.WithdrawDate = Convert.ToString(dr["WithdrawDate"]);
							siblingModel.WithdrawAt = Convert.ToInt32(dr["WithdrawAt"]);
							siblingModel.WithdrawAtTermName = Convert.ToString(dr["WithdrawAtTermName"]);
							siblingModel.WithdrawYear = Convert.ToString(dr["WithdrawYear"]);
							siblingModel.TermId = Convert.ToInt32(dr["TermId"]);
							siblingModel.TermName = Convert.ToString(dr["TermName"]);
							siblingModel.AdmissionYear = Convert.ToString(dr["AdmissionYear"]);
							siblingModel.PrinceAccount = Convert.ToBoolean(dr["PrinceAccount"]);
							siblingModel.IsActive = Convert.ToBoolean(dr["IsActive"]);
							StudentSiblingList.Add(siblingModel);
						}
						model.StudentSiblingList = StudentSiblingList;
					}
				}
				return model;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:StudentService:GetStudentById : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<DataSet> GetStudents(StudentFilterModel filterMode)
		{
			try
			{
				DataSet ds = await _StudentRepo.GetStudents(0, filterMode);
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:StudentService:GetStudents : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<int> SaveStudent(int loginUserId, StudentModel model)
		{
			try
			{
				int result = await _StudentRepo.SaveStudent(loginUserId, model);
				return result;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:StudentService:SaveStudent : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<int> DeleteStudent(int loginUserId, int studentId)
		{
			try
			{
				int result = await _StudentRepo.DeleteStudent(loginUserId, studentId);
				return result;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:StudentService:DeleteStudent : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<int> UpdateStudentProfilePicture(int loginUserId, int studentId, string ImgPath)
		{
			try
			{
				int result = await _StudentRepo.UpdateStudentImage(loginUserId, studentId, ImgPath);
				return result;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:StudentService:UpdateStudentProfilePicture : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<List<GradeModel>> GetGrades(int costCenterId)
		{
			try
			{
				List<GradeModel> gradeModelList = new List<GradeModel>();
				DataSet ds = await _StudentRepo.GetGrades(costCenterId);
				if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
				{
					gradeModelList = (from DataRow dr in ds.Tables[0].Rows
									  select new GradeModel()
									  {
										  GradeId = Convert.ToInt32(dr["SValue"]),
										  GradeName = Convert.ToString(dr["SText"]),
									  }).ToList();


				}
				return gradeModelList;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:StudentService:GetGrades : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<DataSet> GetParentLookup(ParentLookupModel model)
		{
			try
			{
				return await _StudentRepo.GetParentLookup(model);
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:StudentService:GetParentLookup : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<int> FinalStudentWithdraw(int loginUserId, long studentId)
		{
			try
			{
				return await _StudentRepo.FinalStudentWithdraw(loginUserId, studentId);
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:StudentService:GetParentLookup : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}


		#endregion

		#region Student Fee Detail
		public async Task<DataSet> GetStudentFeeDetail(int studentId)
		{
			try
			{
				DataSet ds = await _StudentRepo.GetStudentFeeDetail(studentId, 0);
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:StudentService:GetStudentFeeDetail : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}

		public async Task<DataSet> GetStudentFeeStatement(int academicYearId, int parentId, int studentId)
		{
			try
			{
				DataSet ds = await _StudentRepo.GetStudentFeeStatement(academicYearId, parentId, studentId);
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:StudentService:GetStudentFeeStatement : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}

		public async Task<StudentFeeMasterModel> GetStudentFeeDetailById(int studentId, int studentFeeDetailId)
		{
			try
			{
				StudentFeeMasterModel model = new StudentFeeMasterModel();
				DataSet ds = await _StudentRepo.GetStudentFeeDetail(studentId, 0);
				if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
				{
					model.StudentFeeDetailId = Convert.ToInt32(ds.Tables[0].Rows[0]["StudentFeeDetailId"]);
					model.StudentId = Convert.ToInt32(ds.Tables[0].Rows[0]["StudentId"]);
					model.AcademicYearId = Convert.ToInt32(ds.Tables[0].Rows[0]["AcademicYearId"]);
					model.GradeId = Convert.ToInt32(ds.Tables[0].Rows[0]["GradeId"]);
					model.FeeTypeId = Convert.ToInt32(ds.Tables[0].Rows[0]["FeeTypeId"]);
					model.FeeAmount = Convert.ToDecimal(ds.Tables[0].Rows[0]["FeeAmount"]);
				}
				return model;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:StudentService:GetStudentFeeDetailById : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}

		public async Task<string> GetStudentGradeAr(long studentId)
		{
			try
			{
				string gradeId = "";
				DataSet ds = await _StudentRepo.GetStudentGrade(studentId);
				if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
				{
					gradeId = ds.Tables[0].Rows[0]["GradeNameArabic"].ToString();
				}
				return gradeId;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:StudentService:GetStudentGrade : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}


		public async Task<int> GetStudentGrade(long studentId)
		{
			try
			{
				int gradeId = 0;
				DataSet ds = await _StudentRepo.GetStudentGrade(studentId);
				if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
				{
					gradeId = Convert.ToInt32(ds.Tables[0].Rows[0]["GradeId"]);
				}
				return gradeId;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:StudentService:GetStudentGrade : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}

		public async Task<decimal> GetStudentFeeTypeAmount(long studentId, long gradeId, long feeTypeId, long academicYearId)
		{
			try
			{
				decimal feeAmount = 0;
				DataSet ds = await _StudentRepo.GetStudentFeeTypeAmount(studentId, gradeId, feeTypeId, academicYearId);
				if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
				{
					feeAmount = Convert.ToDecimal(ds.Tables[0].Rows[0]["FeeAmount"]);
				}
				return feeAmount;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:StudentService:GetStudentFeeTypeAmount : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}

		public async Task<int> SaveStudentFeeDetail(int loginUserId, StudentFeeMasterModel model)
		{
			try
			{
				int result = await _StudentRepo.SaveStudentFeeDetail(loginUserId, model);
				return result;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:StudentService:SaveStudentFeeDetail : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}

		public async Task<int> DeleteStudentFeeDetail(int loginUserId, long studentFeeDetailId)
		{
			try
			{
				int result = await _StudentRepo.DeleteStudentFeeDetail(loginUserId, studentFeeDetailId);
				return result;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:StudentService:DeleteStudentFeeDetail : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		#endregion

		#region sibling
		public async Task<DataSet> GetSiblingDiscountDetail(long studentId)
		{
			try
			{
				DataSet ds = await _StudentRepo.GetSiblingDiscountDetail(studentId);
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:StudentService:GetSiblingDiscountDetail : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}

		public async Task<int> SaveSiblingDiscountDetail(int loginUserId, SiblingDiscountDetailModel model)
		{
			try
			{
				int result = await _StudentRepo.SaveSiblingDiscountDetail(loginUserId, model);
				return result;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:StudentService:SaveSiblingDiscountDetail : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<int> DeleteStudentSiblingDiscountDetail(int loginUserId, long studentSiblingDiscountDetailId)
		{
			try
			{
				int result = await _StudentRepo.DeleteStudentSiblingDiscountDetail(loginUserId, studentSiblingDiscountDetailId);
				return result;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:StudentService:DeleteStudentSiblingDiscountDetail : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}

		public async Task<int> UpdateSiblingDiscountStatus(int loginUserId, int actionId, long studentSiblingDiscountDetailId)
		{
			try
			{
				int result = await _StudentRepo.UpdateSiblingDiscountStatus(loginUserId, actionId, studentSiblingDiscountDetailId);
				return result;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:StudentService:UpdateSiblingDiscountStatus : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		#endregion

		#region Other Discount
		public async Task<DataSet> GetOtherDiscountDetail(long studentId)
		{
			try
			{
				DataSet ds = await _StudentRepo.GetOtherDiscountDetail(studentId);
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:StudentService:GetOtherDiscountDetail : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}

		public async Task<int> SaveOtherDiscountDetail(int loginUserId, OtherDiscountDetailModel model)
		{
			try
			{
				int result = await _StudentRepo.SaveOtherDiscountDetail(loginUserId, model);
				return result;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:StudentService:SaveOtherDiscountDetail : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<int> DeleteStudentOtherDiscountDetail(int loginUserId, long studentOtherDiscountDetailId)
		{
			try
			{
				int result = await _StudentRepo.DeleteStudentOtherDiscountDetail(loginUserId, studentOtherDiscountDetailId);
				return result;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:StudentService:DeleteStudentOtherDiscountDetail : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<int> UpdateOtherDiscountStatus(int loginUserId, int actionId, long studentOtherDiscountDetailId)
		{
			try
			{
				int result = await _StudentRepo.UpdateOtherDiscountStatus(loginUserId, actionId, studentOtherDiscountDetailId);
				return result;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:StudentService:UpdateOtherDiscountStatus : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		#endregion
	}
}
