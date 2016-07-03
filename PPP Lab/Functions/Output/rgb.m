function palette = rgb(name)
% RGB  Rgb triple for given CSS color name
%
%   RGB = RGB('COLORNAME') returns the red-green-blue triple corresponding
%     to the color named COLORNAME by the CSS3 proposed standard [1], which
%     contains 139 different colors (an rgb triple is a 1x3 vector of
%     numbers between 0 and 1). COLORNAME is case insensitive, and for gray
%     colors both spellings (gray and grey) are allowed.
%
%   RGB CHART creates a figure window showing all the available colors with
%     their names.
%
%   EXAMPLES
%     c = rgb('DarkRed')               gives c = [0.5430 0 0]
%     c = rgb('Green')                 gives c = [0 0.5 0]
%     plot(x,y,'color',rgb('orange'))  plots an orange line through x and y
%     rgb chart                        shows all the colors
%
%   BACKGROUND
%     The color names of [1] have already been ratified in [2], and
%     according to [3] they are accepted by almost all web browsers and are
%     used in Microsoft's .net framework. All but four colors agree with
%     the X11 colornames, as detailed in [4]. Of these the most important
%     clash is green, defined as [0 0.5 0] by CSS and [0 1 0] by X11. The
%     definition of green in Matlab matches the X11 definition and gives a
%     very light green, called lime by CSS (many users of Matlab have
%     discovered this when trying to color graphs with 'g-'). Note that
%     cyan and aqua are synonyms as well as magenta and fuchsia.
%
%   ABOUT RGB
%     Based on the work off:
%     This program is public domain and may be distributed freely.
%     Author: Kristj�n J�nasson, Dept. of Computer Science, University of
%     Iceland (jonasson@hi.is). June 2009.
%
%   REFERENCES
%     [1] "CSS Color module level 3", W3C (World Wide Web Consortium)
%         working draft 21 July 2008, http://www.w3.org/TR/css3-color
%
%     [2] "Scalable Vector Graphics (SVG) 1.1 specification", W3C
%         recommendation 14 January 2003, edited in place 30 April 2009,
%         http://www.w3.org/TR/SVG
%
%     [3] "Web colors", http://en.wikipedia.org/wiki/Web_colors
%
%     [4] "X11 color names" http://en.wikipedia.org/wiki/X11_color_names

    persistent nbColors colorname
    if isempty(nbColors) % First time rgb is called
        [nbColors,colorname] = getcolors();
        colorname = lower(colorname);
        nbColors = reshape(hex2dec(nbColors), [], 3);
        % Divide most numbers by 256 for "aesthetic" reasons (green=[0 0.5 0])
        I = nbColors < 240;  % (interpolate F0--FF linearly from 240/256 to 1.0)
        nbColors(I) = nbColors(I)/256;
        nbColors(~I) = ((nbColors(~I) - 240)/15 + 15)/16; + 240;
    end

    palette = zeros(1,3);
    k = find(strcmpi(name, colorname));
    if isempty(k)
        if ~strcmpi(name,'random')
            fprintf('Using random color\n');
        end
        palette(:,:) = [rand rand rand];
    else
        palette(:,:) = nbColors(k(1), :);
    end
 
end

function [hex,name] = getcolors()
  css = {
    %White colors
    'FF','FF','FF', 'White'
    'FF','FA','FA', 'Snow'
    'F0','FF','F0', 'Honeydew'
    'F5','FF','FA', 'Mint Cream'
    'F0','FF','FF', 'Azure'
    'F0','F8','FF', 'Alice Blue'
    'F8','F8','FF', 'Ghost White'
    'F5','F5','F5', 'White Smoke'
    'FF','F5','EE', 'Seashell'
    'F5','F5','DC', 'Beige'
    'FD','F5','E6', 'Old Lace'
    'FF','FA','F0', 'Floral White'
    'FF','FF','F0', 'Ivory'
    'FA','EB','D7', 'Antique White'
    'FA','F0','E6', 'Linen'
    'FF','F0','F5', 'Lavender Blush'
    'FF','E4','E1', 'Misty Rose'
    %Grey colors'
    '80','80','80', 'Gray'
    'DC','DC','DC', 'Gainsboro'
    'D3','D3','D3', 'Light Gray'
    'C0','C0','C0', 'Silver'
    'A9','A9','A9', 'Dark Gray'
    '69','69','69', 'Dim Gray'
    '77','88','99', 'Light Slate Gray'
    '70','80','90', 'Slate Gray'
    '2F','4F','4F', 'Dark Slate Gray'
    '00','00','00', 'Black'
    %Red colors
    'FF','00','00', 'Red'
    'FF','A0','7A', 'Light Salmon'
    'FA','80','72', 'Salmon'
    'E9','96','7A', 'Dark Salmon'
    'F0','80','80', 'Light Coral'
    'CD','5C','5C', 'Indian Red'
    'DC','14','3C', 'Crimson'
    'B2','22','22', 'Fire Brick'
    '8B','00','00', 'Dark Red'
    %Pink colors
    'FF','C0','CB', 'Pink'
    'FF','B6','C1', 'Light Pink'
    'FF','69','B4', 'Hot Pink'
    'FF','14','93', 'Deep Pink'
    'DB','70','93', 'Pale Violet Red'
    'C7','15','85', 'Medium Violet Red'
    %Orange colors
    'FF','A5','00', 'Orange'
    'FF','8C','00', 'Dark Orange'
    'FF','7F','50', 'Coral'
    'FF','63','47', 'Tomato'
    'FF','45','00', 'Orange Red'
    %Yellow colors
    'FF','FF','00', 'Yellow'
    'FF','FF','E0', 'Light Yellow'
    'FF','FA','CD', 'Lemon Chiffon'
    'FA','FA','D2', 'Light Goldenrod Yellow'
    'FF','EF','D5', 'Papaya Whip'
    'FF','E4','B5', 'Moccasin'
    'FF','DA','B9', 'Peach Puff'
    'EE','E8','AA', 'Pale Goldenrod'
    'F0','E6','8C', 'Khaki'
    'BD','B7','6B', 'Dark Khaki'
    'FF','D7','00', 'Gold'
    %Brown colors
    'A5','2A','2A', 'Brown'
    'FF','F8','DC', 'Cornsilk'
    'FF','EB','CD', 'Blanched Almond'
    'FF','E4','C4', 'Bisque'
    'FF','DE','AD', 'Navajo White'
    'F5','DE','B3', 'Wheat'
    'DE','B8','87', 'Burly Wood'
    'D2','B4','8C', 'Tan'
    'BC','8F','8F', 'Rosy Brown'
    'F4','A4','60', 'Sandy Brown'
    'DA','A5','20', 'Goldenrod'
    'B8','86','0B', 'Dark Goldenrod'
    'CD','85','3F', 'Peru'
    'D2','69','1E', 'Chocolate'
    '8B','45','13', 'Saddle Brown'
    'A0','52','2D', 'Sienna'
    '80','00','00', 'Maroon'
    %Green colors
    '00','80','00', 'Green'
    '98','FB','98', 'Pale Green'
    '90','EE','90', 'Light Green'
    '9A','CD','32', 'Yellow Green'
    'AD','FF','2F', 'Green Yellow'
    '7F','FF','00', 'Chartreuse'
    '7C','FC','00', 'Lawn Green'
    '00','FF','00', 'Lime'
    '32','CD','32', 'Lime Green'
    '00','FA','9A', 'Medium Spring Green'
    '00','FF','7F', 'Spring Green'
    '66','CD','AA', 'Medium Aquamarine'
    '7F','FF','D4', 'Aquamarine'
    '20','B2','AA', 'Light Sea Green'
    '3C','B3','71', 'Medium Sea Green'
    '2E','8B','57', 'Sea Green'
    '8F','BC','8F', 'Dark Sea Green'
    '22','8B','22', 'Forest Green'
    '00','64','00', 'Dark Green'
    '6B','8E','23', 'Olive Drab'
    '80','80','00', 'Olive'
    '55','6B','2F', 'Dark Olive Green'
    '00','80','80', 'Teal'
    %Blue colors
    '00','00','FF', 'Blue'
    'AD','D8','E6', 'Light Blue'
    'B0','E0','E6', 'Powder Blue'
    'AF','EE','EE', 'Pale Turquoise'
    '40','E0','D0', 'Turquoise'
    '48','D1','CC', 'Medium Turquoise'
    '00','CE','D1', 'Dark Turquoise'
    'E0','FF','FF', 'Light Cyan'
    '00','FF','FF', 'Cyan'
    '00','FF','FF', 'Aqua'
    '00','8B','8B', 'Dark Cyan'
    '5F','9E','A0', 'Cadet Blue'
    'B0','C4','DE', 'Light Steel Blue'
    '46','82','B4', 'Steel Blue'
    '87','CE','FA', 'Light Sky Blue'
    '87','CE','EB', 'Sky Blue'
    '00','BF','FF', 'Deep Sky Blue'
    '1E','90','FF', 'Dodger Blue'
    '64','95','ED', 'Cornflower Blue'
    '41','69','E1', 'Royal Blue'
    '00','00','CD', 'Medium Blue'
    '00','00','8B', 'Dark Blue'
    '00','00','80', 'Navy'
    '19','19','70', 'Midnight Blue'
    %Purple colors
    '80','00','80', 'Purple'
    'E6','E6','FA', 'Lavender'
    'D8','BF','D8', 'Thistle'
    'DD','A0','DD', 'Plum'
    'EE','82','EE', 'Violet'
    'DA','70','D6', 'Orchid'
    'FF','00','FF', 'Fuchsia'
    'FF','00','FF', 'Magenta'
    'BA','55','D3', 'Medium Orchid'
    '93','70','DB', 'Medium Purple'
    '99','66','CC', 'Amethyst'
    '8A','2B','E2', 'Blue Violet'
    '94','00','D3', 'Dark Violet'
    '99','32','CC', 'Dark Orchid'
    '8B','00','8B', 'Dark Magenta'
    '6A','5A','CD', 'Slate Blue'
    '48','3D','8B', 'Dark Slate Blue'
    '7B','68','EE', 'Medium Slate Blue'
    '4B','00','82', 'Indigo'
    %Gray repeated with spelling grey
    '80','80','80', 'Grey'
    'D3','D3','D3', 'Light Grey'
    'A9','A9','A9', 'Dark Grey'
    '69','69','69', 'Dim Grey'
    '77','88','99', 'Light Slate Grey'
    '70','80','90', 'Slate Grey'
    '2F','4F','4F', 'Dark Slate Grey'
    };
  hex = css(:,1:3);
  name = css(:,4);
end