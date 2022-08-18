pub usingnamespace @cImport({
    @cDefine("STBI_ONLY_PNG", "");
    @cDefine("STB_IMAGE_IMPLEMENTATION", "");
    @cInclude("stb_image.h");
});
