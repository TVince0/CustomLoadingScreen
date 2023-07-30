Json::Value g_json;
[Setting name="Custom Image URL" category="General" description="The URL of your custom loading screen image"]
string Setting_CustomImage_URL = "";

bool g_wasShow = false;
UI::Texture@ m_loading_icon;
UI::Font@ m_text_font_big;
float m_loading_current_rotation = 0;

void Render()
{
   auto loadProgress = GetApp().LoadProgress;
   if (loadProgress is null || loadProgress.State == NGameLoadProgress_SMgr::EState::Disabled) {
      if(g_wasShow) {
         PreloadImage(Setting_CustomImage_URL);
      }
      g_wasShow = false;
      return;
   }

   UI::DrawList@ drawList = UI::GetBackgroundDrawList();

   if (Setting_CustomImage_URL != "") {
      auto img = Images::CachedFromURL(Setting_CustomImage_URL);
      if (img.m_texture !is null) {
         drawList.AddImage(img.m_texture, vec2(0, 0), vec2(Draw::GetWidth(), Draw::GetHeight()));
      }
   }

   // Loading spinner
   // (remaining code remains the same)
}

void PreloadImage(const string& in imageURL) {
   if (imageURL != "") {
      Images::CachedFromURL(imageURL);
   }
}

void Main()
{
   @m_loading_icon = UI::LoadTexture("loading_icon.png");
   @m_text_font_big = UI::LoadFont("LEMONMILK-Medium.otf", 77);

   if (Setting_CustomImage_URL != "") {
      print("Using custom loading screen image from URL: " + Setting_CustomImage_URL);
      PreloadImage(Setting_CustomImage_URL);
   } else {
      print("Downloading default loading screens JSON ..");
      auto response = Net::HttpGet("https://openplanet.dev/plugin/betterloadingscreen/config/loading_screens");
      while (!response.Finished()) {
         yield();
      }
      g_json = Json::Parse(response.String());
      g_wasShow = true;
   }
   yield();
}
