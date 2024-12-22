using School.Models.WebModels.StudentModels;

namespace School.Models.WebModels.ParentModels
{
	public class ParentModel
    {
        public ParentModel()
        {
            IsFatherStaff=false;
            IsMotherStaff=false;
            IsActive = true;
        }
        public int ParentId { get; set; }
        public string ParentCode { get; set; }
        public string ParentImage { get; set; }
        public string FatherName { get; set; }
        public string FatherArabicName { get; set; }
        public int FatherNationalityId { get; set; }
        public string FatherMobile { get; set; }
        public string FatherEmail { get; set; }
        public string FatherIqamaNo { get; set; }
        public bool IsFatherStaff { get; set; }
        public string FatherCountryName { get; set; }


        public string MotherName { get; set; }
        public string MotherArabicName { get; set; }
        public int MotherNationalityId { get; set; }
        public string MotherMobile { get; set; }
        public string MotherEmail { get; set; }
        public string MotherIqamaNo { get; set; }
        public bool IsMotherStaff { get; set; }
        public bool IsActive { get; set; }
        public string MotherCountryName { get; set; }

        public List<StudentModel> StudentModelList { get; set; }
        public ParentAccountModel AccountModel { get; set; }
    }
}
