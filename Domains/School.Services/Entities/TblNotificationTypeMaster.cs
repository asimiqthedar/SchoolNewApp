﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
#nullable disable
using System;
using System.Collections.Generic;

namespace School.Services.Entities;

public partial class TblNotificationTypeMaster
{
    public int NotificationTypeId { get; set; }

    public string NotificationType { get; set; }

    public string ActionTable { get; set; }

    public string NotificationMsg { get; set; }

    public bool IsActive { get; set; }

    public string NotificationActionTable { get; set; }
}