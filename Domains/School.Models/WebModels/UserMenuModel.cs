namespace School.Models.WebModels
{
	public class UserMenuModel
    {
        public int MenuId { get; set; }
        public string Menu { get; set; }
        public string MenuCtrl { get; set; }
        public string MenuAction { get; set; }
        public int ParentMenuId { get; set; }
        public int DisplaySequence { get; set; }
        public string FaIcon { get; set; }
        public int Level { get; set; }
        public string Hierarchy { get; set; }
    }
}
