namespace School.Models.WebModels.NotificationModels
{
	public class NotificationGroupModel
    {
        public int NotificationGroupId { get; set; }
        public int NotificationTypeId { get; set; }
        public int NotificationCount { get; set; }
        public string NotificationAction { get; set; }
        public string NotificationType { get; set; }
        public string ActionTable { get; set; }
        public string NotificationMsg { get; set; }
    }
}
