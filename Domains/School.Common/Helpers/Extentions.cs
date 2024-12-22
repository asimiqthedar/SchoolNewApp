using System.Data;

namespace School.Common.Helpers
{
	public static class Extentions
    {
        public static string Decrypt(this string Str)
        {
            var tempStr = string.Empty;
            if (!string.IsNullOrWhiteSpace(Str))
                tempStr = Str.Replace(" ", "+");

            string val = Utility.Decrypt(tempStr, false);
            if (val == "")
                return Utility.Decrypt(tempStr, true);
            else
                return val;
        }
        public static string Encrypt(this string Str, bool urlEncode = false)
        {
            return Utility.Encrypt(Str, urlEncode);
        }
        public static DateTime SetDateformat(this string strdate)
        {
            DateTime date;
            DateTime.TryParseExact(strdate, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out date);
            return date;
        }
        public static decimal ToDecimalPoints(this decimal input, int decimalPoints = 2)
        {
            return Decimal.Round(input, decimalPoints);
        }
        public static string ToTwoDecimalString(this decimal input)
        {
            return input.ToString("#,##0.00");
        }

        public static List<T> ConvertToList<T>(DataTable dt)
        {
            var columnNames = dt.Columns.Cast<DataColumn>().Select(c => c.ColumnName.ToLower()).ToList();
            var properties = typeof(T).GetProperties();
            return dt.AsEnumerable().Select(row => {
                var objT = Activator.CreateInstance<T>();
                foreach (var pro in properties)
                {
                    if (columnNames.Contains(pro.Name.ToLower()))
                    {
                        try
                        {
                            pro.SetValue(objT, row[pro.Name]);
                        }
                        catch (Exception ex) { }
                    }
                }
                return objT;
            }).ToList();
        }

    }
}
