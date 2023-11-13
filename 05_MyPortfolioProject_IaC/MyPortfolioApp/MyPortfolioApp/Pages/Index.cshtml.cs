using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using MyPortfolioApp.Models;
using MyPortfolioApp.Services;

namespace MyPortfolioApp.Pages
{
    public class IndexModel : PageModel
    {
        private readonly IImageService _imageService;

        public IndexModel(IImageService imageService)
        {
            _imageService = imageService;
        }

        public List<Image> Images;
        public void OnGet()
        {
            Images = _imageService.GetImages();

        }
    }


}