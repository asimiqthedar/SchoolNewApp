using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using System.Text;

namespace School.Web.Results
{
	public class JsonNetResult : ActionResult
    {
        public Encoding ContentEncoding { get; set; }
        public string ContentType { get; set; }
        public object Data { get; set; }

        public JsonSerializerSettings SerializerSettings { get; set; }
        public Formatting Formatting { get; set; }

        public JsonNetResult()
        {
            SerializerSettings = new JsonSerializerSettings();
        }

        public JsonNetResult(object Data)
        {
            SerializerSettings = new JsonSerializerSettings();
            this.Data = Data;
        }
    }
}
