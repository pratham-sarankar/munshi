import { Github, Twitter, Mail, Heart } from "lucide-react";
import logo from "../assets/logo.png";

export function Footer() {
  return (
    <footer className="bg-[#0F172A] text-gray-300 px-6 py-12 md:py-16">
      <div className="mx-auto max-w-7xl">
        <div className="grid gap-8 md:gap-12 md:grid-cols-2 lg:grid-cols-4 mb-12">
          <div>
            <div className="flex items-center gap-2 mb-4">
              <img src={logo} alt="Munshi Logo" className="w-8 h-8" />
              <span className="text-xl text-white">Munshi</span>
            </div>
            <p className="text-sm mb-6 text-gray-400">
              Your intelligent expense tracking companion. Simple, private, and open source.
            </p>
            <div className="flex gap-4">
              <a 
                href="https://github.com/pratham-sarankar/munshi" 
                target="_blank" 
                rel="noopener noreferrer"
                className="hover:text-white transition-colors"
              >
                <Github className="h-5 w-5" />
              </a>
              <a href="#" className="hover:text-white transition-colors">
                <Twitter className="h-5 w-5" />
              </a>
              <a href="mailto:support@munshi.app" className="hover:text-white transition-colors">
                <Mail className="h-5 w-5" />
              </a>
            </div>
          </div>
          
          <div>
            <h3 className="text-white mb-4">Product</h3>
            <ul className="space-y-3 text-sm">
              <li><a href="#features" className="hover:text-white transition-colors">Features</a></li>
              <li><a href="#screenshots" className="hover:text-white transition-colors">Screenshots</a></li>
              <li><a href="#how-it-works" className="hover:text-white transition-colors">How It Works</a></li>
              <li><a href="#faq" className="hover:text-white transition-colors">FAQ</a></li>
            </ul>
          </div>
          
          <div>
            <h3 className="text-white mb-4">Resources</h3>
            <ul className="space-y-3 text-sm">
              <li>
                <a 
                  href="https://github.com/pratham-sarankar/munshi" 
                  target="_blank" 
                  rel="noopener noreferrer"
                  className="hover:text-white transition-colors"
                >
                  GitHub Repository
                </a>
              </li>
              <li>
                <a 
                  href="https://github.com/pratham-sarankar/munshi/blob/main/README.md" 
                  target="_blank" 
                  rel="noopener noreferrer"
                  className="hover:text-white transition-colors"
                >
                  Documentation
                </a>
              </li>
              <li>
                <a 
                  href="https://github.com/pratham-sarankar/munshi/issues" 
                  target="_blank" 
                  rel="noopener noreferrer"
                  className="hover:text-white transition-colors"
                >
                  Report a Bug
                </a>
              </li>
              <li>
                <a 
                  href="https://github.com/pratham-sarankar/munshi/blob/main/LICENSE" 
                  target="_blank" 
                  rel="noopener noreferrer"
                  className="hover:text-white transition-colors"
                >
                  License (MIT)
                </a>
              </li>
            </ul>
          </div>
          
          <div>
            <h3 className="text-white mb-4">Legal</h3>
            <ul className="space-y-3 text-sm">
              <li><a href="#" className="hover:text-white transition-colors">Privacy Policy</a></li>
              <li><a href="#" className="hover:text-white transition-colors">Terms of Service</a></li>
              <li><a href="mailto:support@munshi.app" className="hover:text-white transition-colors">Contact</a></li>
            </ul>
          </div>
        </div>
        
        <div className="border-t border-gray-800 pt-8 flex flex-col md:flex-row justify-between items-center gap-4 text-sm">
          <p className="text-gray-400">
            © {new Date().getFullYear()} Munshi. Open source under MIT License.
          </p>
          <div className="flex items-center gap-2 text-gray-400">
            <span>Built with Flutter and</span>
            <Heart className="h-4 w-4 text-red-500 fill-red-500" />
            <span>in India</span>
          </div>
        </div>
      </div>
    </footer>
  );
}
