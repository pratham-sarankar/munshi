import { Button } from "./ui/button";
import { Download, Github, Smartphone } from "lucide-react";

export function CTA() {
  return (
    <section className="px-6 py-16 md:py-24 bg-gradient-to-br from-[#5856D6] to-[#4845B8] relative overflow-hidden">
      {/* Decorative elements */}
      <div className="absolute top-0 right-0 w-96 h-96 bg-white/5 rounded-full blur-3xl"></div>
      <div className="absolute bottom-0 left-0 w-96 h-96 bg-[#7C7FFF]/10 rounded-full blur-3xl"></div>
      
      <div className="mx-auto max-w-4xl relative text-center">
        <div className="space-y-6 md:space-y-8 text-white">
          <h2 className="text-3xl md:text-4xl lg:text-5xl">
            Ready to take control of your finances?
          </h2>
          <p className="text-lg md:text-xl text-white/90 max-w-2xl mx-auto">
            Download Munshi today and start tracking your expenses with ease. 
            Free, open source, and designed for privacy.
          </p>
          
          <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
            <Button 
              size="lg" 
              className="bg-white text-[#5856D6] hover:bg-white/90 shadow-lg rounded-xl px-8 w-full sm:w-auto"
            >
              <Download className="mr-2 h-5 w-5" />
              Download on Google Play
            </Button>
            <a 
              href="https://github.com/pratham-sarankar/munshi" 
              target="_blank" 
              rel="noopener noreferrer"
              className="w-full sm:w-auto"
            >
              <Button 
                size="lg" 
                variant="outline" 
                className="border-white text-white hover:bg-white/10 rounded-xl px-8 w-full"
              >
                <Github className="mr-2 h-5 w-5" />
                View Source Code
              </Button>
            </a>
          </div>
          
          <div className="flex flex-col sm:flex-row items-center justify-center gap-6 md:gap-8 pt-8 text-sm text-white/80">
            <div className="flex items-center gap-2">
              <Smartphone className="h-5 w-5" />
              <span>Available for Android & iOS</span>
            </div>
            <div className="hidden sm:block w-px h-6 bg-white/20"></div>
            <div className="flex items-center gap-2">
              <Github className="h-5 w-5" />
              <span>Open Source (MIT License)</span>
            </div>
            <div className="hidden sm:block w-px h-6 bg-white/20"></div>
            <div className="flex items-center gap-2">
              <svg className="h-5 w-5" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clipRule="evenodd" />
              </svg>
              <span>100% Private & Local</span>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
