using System.Data;

namespace School.Services.WebServices.Services
{
	public interface IAttachements
    {
        Task<int> SaveAttachements(int DocFor, int DocType, long DocForId, string DocNo, string DocPath, int loginUserId);
        Task<DataSet> GetAttachments(long docForId, int docFor);
        Task<int> DeleteAttachment(int uploadedDocId, int loginUserId);
    }
}
