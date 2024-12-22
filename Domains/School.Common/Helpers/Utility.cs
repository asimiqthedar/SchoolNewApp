using System.Security.Cryptography;
using System.Text;
using System.Web;

namespace School.Common.Helpers
{
	public class Utility
    {
        private static Random random = new Random();
        #region Encrypt/Decrypt
        public static string Encrypt(string strToEncrypt, Boolean bURLEncode)
        {
            try
            {
                string strKey = "qazxswedc";
                string sOutPut = string.Empty;
                TripleDESCryptoServiceProvider objDESCrypto = new TripleDESCryptoServiceProvider();
                MD5CryptoServiceProvider objHashMD5 = new MD5CryptoServiceProvider();
                byte[] byteHash, byteBuff;
                string strTempKey = strKey;
                byteHash = objHashMD5.ComputeHash(ASCIIEncoding.ASCII.GetBytes(strTempKey));
                objHashMD5 = null;
                objDESCrypto.Key = byteHash;
                objDESCrypto.Mode = CipherMode.ECB;
                byteBuff = ASCIIEncoding.ASCII.GetBytes(strToEncrypt);
                sOutPut = Convert.ToBase64String(objDESCrypto.CreateEncryptor().
                    TransformFinalBlock(byteBuff, 0, byteBuff.Length));

                if (bURLEncode)
                    sOutPut = HttpUtility.UrlEncode(sOutPut);
                return sOutPut;
            }
            catch (Exception)
            {
                return "";
            }
        }
        public static string Decrypt(string strEncrypted, Boolean bURLDecode)
        {
            try
            {

                if (bURLDecode)
                {
                    strEncrypted = HttpUtility.UrlDecode(strEncrypted);
                    if (strEncrypted.Contains(" "))
                        strEncrypted = strEncrypted.Replace(" ", "+");
                }
                string strKey = "qazxswedc";
                TripleDESCryptoServiceProvider objDESCrypto =
                    new TripleDESCryptoServiceProvider();
                MD5CryptoServiceProvider objHashMD5 = new MD5CryptoServiceProvider();
                byte[] byteHash, byteBuff;
                string strTempKey = strKey;
                byteHash = objHashMD5.ComputeHash(ASCIIEncoding.ASCII.GetBytes(strTempKey));
                objHashMD5 = null;
                objDESCrypto.Key = byteHash;
                objDESCrypto.Mode = CipherMode.ECB;
                byteBuff = Convert.FromBase64String(strEncrypted);
                string strDecrypted = ASCIIEncoding.ASCII.GetString(objDESCrypto.CreateDecryptor().TransformFinalBlock(byteBuff, 0, byteBuff.Length));
                objDESCrypto = null;
                return strDecrypted;
            }
            catch (Exception)
            {
                return "";
            }
        }
        #endregion       

        public static string RandomString(int length)
        {
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            return new string(Enumerable.Repeat(chars, length)
                .Select(s => s[random.Next(s.Length)]).ToArray());
        }
        public static string GetUniqueFileName(string fileName)
        {
            fileName = Path.GetFileName(fileName);
            return Path.GetFileNameWithoutExtension(fileName)
                      + "_"
                      + Guid.NewGuid().ToString().Substring(0, 4)
                      + Path.GetExtension(fileName);
        }
    }
}
