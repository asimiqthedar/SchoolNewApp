﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
#nullable disable
using System;
using System.Collections.Generic;

namespace School.Services.Entities;

public partial class TblNotification
{
    public long NotificationId { get; set; }

    public string RecordId { get; set; }

    public int RecordStatus { get; set; }

    public bool IsApproved { get; set; }

    public string RecordType { get; set; }

    public DateTime UpdateDate { get; set; }

    public int UpdateBy { get; set; }

    public string StudentId { get; set; }

    public string OldValueJson { get; set; }

    public string NewValueJson { get; set; }
}