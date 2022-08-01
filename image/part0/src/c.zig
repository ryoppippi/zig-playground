pub const c = @cImport({
    @cDefine("STB_IMAGE_IMPLEMENTATION", "");
    @cInclude("stb_image.h");
});
