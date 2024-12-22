

namespace School.Web.Helpers
{
	public class CommonHelper
    {
        private readonly IWebHostEnvironment _env;
        public CommonHelper(IWebHostEnvironment env)
        {
            _env = env;
        }
        public string KeyFilePath(string path = "")
        {
            // Equivalent to Server.MapPath("~/wwwroot")
            var webRootPath = _env.WebRootPath;
            string returnPath;
            if (string.IsNullOrEmpty(path))
                returnPath = Path.Combine(webRootPath, "CertificateFolder", "KeyFiles");
            else
                returnPath = Path.Combine(webRootPath, "CertificateFolder", path);

            if (!System.IO.Directory.Exists(returnPath))
                System.IO.Directory.CreateDirectory(returnPath);

            return returnPath;
        }
        public string KeyFilePath(string folderPath = "", string innerFolder = "")
        {
            // Equivalent to Server.MapPath("~/wwwroot")
            var webRootPath = _env.WebRootPath;
            string returnPath;
            if (string.IsNullOrEmpty(folderPath))
                returnPath = Path.Combine(webRootPath, "CertificateFolder", "KeyFiles");
            else
                returnPath = Path.Combine(webRootPath, "CertificateFolder", folderPath);

            if (!System.IO.Directory.Exists(returnPath))
                System.IO.Directory.CreateDirectory(returnPath);

            if (!string.IsNullOrEmpty(innerFolder))
            {
                returnPath = System.IO.Path.Combine(returnPath, innerFolder);

                if (!System.IO.Directory.Exists(returnPath))
                    System.IO.Directory.CreateDirectory(returnPath);
            }
            return returnPath;
        }
    }
}