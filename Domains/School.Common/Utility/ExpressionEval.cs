using System.Text.RegularExpressions;

namespace School.Common.Utility
{
	public class ExpressionEval
    {
        private Object _Model = null;
        private Object _P1 = null;
        private string _expr = "";
        public ExpressionEval(string expression, object Model, object P1 = null)
        {
            _Model = Model;
            _expr = expression;
            _P1 = P1;
        }

        public string Compile()
        {
            try
            {
                string exp = _expr;
                foreach (Match m in Regex.Matches(exp, @"\{{.*?\}}"))
                {
                    if (m.Success)
                    {
                        string pp = m.Value.Replace("{{", "").Replace("}}", "").Trim();
                        string val_str = "";
                        if (pp.StartsWith("P1") && _P1 != null)
                            val_str = EvalProp(_P1, pp.Replace("P1.", ""));
                        else
                            val_str = EvalProp(_Model, pp);
                        exp = exp.Replace(m.Value.Trim(), val_str);
                    }
                }
                return exp;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        internal string EvalProp(object Ob, string PropName)
        {
            try
            {
                string ret = "";
                Type ValueType = typeof(string);
                Type ObType = Ob.GetType();
                object val = null;
                if (PropName.Contains('.'))
                {
                    string[] arrp = PropName.Split('.');
                    Type f1_type = ObType.GetProperty(arrp[0]).GetValue(Ob).GetType();
                    object f1_value = ObType.GetProperty(arrp[0]).GetValue(Ob);

                    val = ExecuteMember(f1_value, f1_type, arrp[1], out ValueType);
                }
                else
                {
                    val = ExecuteMember(Ob, ObType, PropName, out ValueType);
                }

                if (ValueType == typeof(DateTime) || ValueType == typeof(DateTime?))
                {
                    ret = (val == null) ? DateTime.MinValue.ToString("yyyy-MMM-dd") : ((DateTime)val).ToString("yyyy-MMM-dd");
                }
                else
                    ret = (val == null) ? "" : val.ToString();

                return ret;
            }
            catch
            {
                return "";
            }
        }

        public object ExecuteMember(object Ob, Type ObType, string MemberName, out Type ReturnType)
        {
            try
            {
                object val = null;
                if (MemberName.EndsWith("()"))
                {
                    var mi = ObType.GetMethod(MemberName.Replace("()", ""), new Type[] { });
                    val = mi.Invoke(Ob, null);
                    ReturnType = mi.ReturnType;
                }
                else
                {
                    var prop = ObType.GetProperty(MemberName);
                    val = prop.GetValue(Ob);
                    ReturnType = prop.PropertyType;
                }
                return val;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
    }
}
