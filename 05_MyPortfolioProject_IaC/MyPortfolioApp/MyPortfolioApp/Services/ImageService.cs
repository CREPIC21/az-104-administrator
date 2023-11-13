using MyPortfolioApp.Models;
using System.Data.SqlClient;

namespace MyPortfolioApp.Services
{
    public class ImageService : IImageService
    {
        private readonly IConfiguration _configuration;
        public ImageService(IConfiguration configuration)
        {
            _configuration = configuration;
        }
        private SqlConnection GetConnection()
        {

            return new SqlConnection(_configuration.GetConnectionString("SQLConnection"));
        }
        public List<Image> GetImages()
        {
            List<Image> _image_lst = new List<Image>();
            string _statement = "SELECT ImagePath from Images";
            SqlConnection _connection = GetConnection();

            _connection.Open();

            SqlCommand _sqlcommand = new SqlCommand(_statement, _connection);

            using (SqlDataReader _reader = _sqlcommand.ExecuteReader())
            {
                while (_reader.Read())
                {
                    Image _image = new Image()
                    {
                        ImagePath = _reader.GetString(0)
                    };

                    _image_lst.Add(_image);
                }
            }
            _connection.Close();
            return _image_lst;
        }
    }
}
