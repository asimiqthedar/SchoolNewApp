namespace School.Models.WebModels.UserModels
{
	public class UserModel
    {
        public UserModel()
        {
            IsActive = true;
        }
        public int UserId { get; set; }
        public string UserName { get; set; }
        public string UserArabicName { get; set; }
        public string UserEmail { get; set; }
        public string UserPhone { get; set; }
        public string UserPass { get; set; }
        public int RoleId { get; set; }
        public string RoleName { get; set; }
        public string ProfileImg { get; set; }
        public bool IsApprover { get; set; }
        public bool IsActive { get; set; }
        public List<UserMenuModel> UserMenueList { get; set; }
    }
}
