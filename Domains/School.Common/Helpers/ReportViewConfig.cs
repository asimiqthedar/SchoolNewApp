namespace School.Common.Helpers
{
	public class ListViewConfig: ReportViewConfig
    {
        public ListViewConfig()
        {
            HideDateFilter = true;
            AllowExport = false;
            PageSize = "4";
        }
        public bool AllowEdit { set; get; }
        public string EditAction { set; get; }
        public string IdColumn { set; get; }
        public bool AllowExport { get; set; }
        public bool IsMaster { set; get; }
        public string Controller { set; get; }
        public string Action { set; get; }
        public int StatusConfigId { get; set; }
    }

    public class ReportViewConfig
    {
        public ReportViewConfig(): base()
        {
            Type = ReportFormatOption.Grid;
            Columns = new List<ReportColumn>();
            TotalOnColumns = new List<string>();
            DateFilterType = DateFilterTypeOption.Default;
            //Filters = new List<EntityFilter>();
            AllowSortable = false;
            AvlPrivileges = new List<string>();
            ParameterFilters = new List<ParameterFilter>();
        }
        public string Id { set; get; }
        public List<string> AvlPrivileges { set; get; }
        public ReportFormatOption Type { set; get; }
        public string Name { set; get; }
        public List<ReportColumn> Columns { set; get; }
        public bool DbServerPaging { set; get; }

        public List<string> TotalOnColumns { set; get; }
        public string Description { set; get; }
        /// <summary>
        /// object OrignalSource, ReportViewConfig ReportConfig
        /// </summary>
        public Action<object, ReportViewConfig> AfterQueryExec = null;

        /// <summary>
        /// object OrignalSource, object CreatedSource
        /// </summary>
        //public Action<object, object, ListResponse, ReportViewConfig> BeforeSendingOutput = null;
        public DateFilterTypeOption DateFilterType { set; get; }
        public bool HideDateFilter { set; get; }
        public string DateFilterDefault { set; get; }
        //public List<EntityFilter> Filters { set; get; }
        public bool EnableSearch { set; get; }
        public bool AllowSortable { set; get; }
        public string DefaultSort { set; get; }
        public bool IsBrowser { set; get; }
        public string RecordZeroMsg { set; get; }
        public string TotalAmtTitle { set; get; }
        public string PageSize { set; get; }
        public List<ParameterFilter> ParameterFilters { set; get; }
    }

    //public class EntityFilter
    //{
    //    public EntityFilter(string id, string Caption)
    //    {
    //        Id = id;
    //        EntityId = id;
    //        //this.Name = Name;
    //        this.Caption = Caption; //(Caption == "") ? Name : Caption;
    //        Type = EntityFilterTypeOption.List;
    //        isMandatory = false;
    //        isMultiSelect = false;
    //    }
    //    //public EntityFilter(string Name, EntityFilterTypeOption type = EntityFilterTypeOption.String, string Caption = "")
    //    //{
    //    //    this.Name = Name;
    //    //    this.Caption = (Caption == "") ? Name : Caption;
    //    //    isMandatory = false;
    //    //}

    //    //Used for filter string :: in case of passing threw query string or any other page. like Customer ='xyz'
    //    //or we can use filter_{id}. or we can use enum EntityId name like Account
    //    //public string Name { set; get; }
    //    public string Id { set; get; }        

    //    //Actual entity id to pass to entitylist
    //    public string EntityId { set; get; }
    //    public string Caption { set; get; }
    //    public bool isMandatory { set; get; }
    //    public bool isMultiSelect { set; get; }
    //    public EntityFilterTypeOption Type { set; get; }
    //    //public string RefDataFilter { set; get; }
    //    public string DefaultValue { set; get; }//comma seperated for multiple values
    //    public bool DateDepend { set; get; }
    //    //public List<string> DependUpons { set; get; }//
    //    public string DataFilter { set; get; }

    //    public List<ExpFilter> ExpFilter { set; get; }

    //    public List<string> Options { set; get; }

    //    /// <summary>
    //    /// Used if filter Type is Options
    //    /// </summary>
    //    public Dictionary<string,string> Type_Options_Values { set; get; }
    //}

    public class ParameterFilter
    {
        public string ParameterKey { get; set; }
        public string ParameterValue { get; set; }
    }
    public enum ReportFormatOption
    {
        Grid,
        Tree,
        Pivot,
        Chart,
        Card
    }

    public enum EntityFilterTypeOption
    {
        List = 1,
        Tree = 2,
        String = 3,
        Date = 4,
        Amount = 5,
        Bool = 6,
        Integer = 7,
        Options = 8
    }

    public enum DateFilterTypeOption
    {
        Default = 1,
        Year = 2,
        YearMonth = 3,
        FinancialYear = 4,
        FinancialYearMonth = 5,
        TillDate = 6,
        DateRange=7
    }

    public class ReportColumn
    {
        public ReportColumn()
        {
            Format = ColumnFormat.General; Editable = false; FormatString = "";
        }
        public ColumnFormat Format { set; get; }
        public string FormatString { set; get; }
        public string Name { set; get; }
        public string Caption { set; get; }
        public string Width { set; get; }
        //public ActionFormat Link { set; get; }
        public string Info { set; get; }
        public bool Hidden { set; get; }
        public bool Editable { set; get; }
        public bool IsStatusCol { get; set; }
        public string Orderable { set; get; }
    }

    public enum ColumnFormat
    {
        General,
        Amount,        
        Int,
        Date,
        Time,
        Image,
        CheckBox,
        Icon,
        DateTime,
        Rate
    }

    public enum ChartTypeOption
    {
        Bar = 1,
        Line = 2,
        Pie = 3,
        Area = 4
    }   
}
