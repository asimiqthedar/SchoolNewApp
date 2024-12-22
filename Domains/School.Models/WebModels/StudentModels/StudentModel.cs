namespace School.Models.WebModels.StudentModels
{
	public class StudentModel
    {
        public StudentModel()
        {
            IsGPIntegration = false;
            PrinceAccount = false;
            IsActive = true;
        }
        public int StudentId { get; set; }
        public string StudentCode { get; set; }
        public string StudentImage { get; set; }
        public int ParentId { get; set; }
        public string ParentCode { get; set; }
        public string StudentName { get; set; }
        public string StudentArabicName { get; set; }
        public string StudentEmail { get; set; }
        public string DOB { get; set; }
        public string IqamaNo { get; set; }
        public int NationalityId { get; set; }
        public string CountryName { get; set; }
        public int GenderId { get; set; }
        public string GenderTypeName { get; set; }
        public string AdmissionDate { get; set; }
        public int CostCenterId { get; set; }
        public string CostCenterName { get; set; }
        public int GradeId { get; set; }
        public string GradeName { get; set; }

		public string GradeNameArabic { get; set; }
		public int SectionId { get; set; }
        public string SectionName { get; set; }
        public string PassportNo { get; set; }
        public string PassportExpiry { get; set; }
        public string Mobile { get; set; }
        public string StudentAddress { get; set; }
        public int StudentStatusId { get; set; }
        public string StatusName { get; set; }
        public decimal Fees { get; set; }
        public bool IsGPIntegration { get; set; }
        public string WithdrawDate { get; set; }
        public int WithdrawAt { get; set; }
        public string WithdrawAtTermName { get; set; }
        public string WithdrawYear { get; set; }
        public int TermId { get; set; }
        public string TermName { get; set; }
        public string AdmissionYear { get; set; }
        public bool PrinceAccount { get; set; }
        public bool IsActive { get; set; }
        public StudentParentModel ParentModel { get; set; }
        public List<StudentModel> StudentSiblingList { get; set; }
        public List<StudentFeeMasterModel> FeeMasterModel { get; set; }  

    }
}
