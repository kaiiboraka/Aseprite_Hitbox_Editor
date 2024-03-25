from zipfile import *
import os

def main():
    directory = '.'
    with ZipFile('Aseprite_Hitbox_Editor.aseprite-extension', 'w') as myzip:
        for file in os.listdir(directory):
            if file.find(".py") != -1: continue
            if file.find(".gitignore") != -1: continue
            if file.find(".ase") != -1:
                if file.find(".aseprite-extension") == -1:
                    continue
            
            f = os.path.join(directory, file)
            if (os.path.isfile(f)):
                myzip.write(f)

if __name__ == "__main__":
    main()