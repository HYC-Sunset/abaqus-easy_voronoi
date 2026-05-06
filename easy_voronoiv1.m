% Seed Generator v1: English UI + license guard
% Compatible with matlab2abaqus.py / Abaqus scripts
% author: SDU-hyc
% email: 202437682@mail.sdu.edu.cn
% This tool is free for academic use. If you use it in your research,
% please cite: https://doi.org/10.1016/j.jmrt.2026.01.083

function interactive_voronoi
actionFlag = '';

% ===== Manually input len and wid =====
prompt   = {'Enter domain length len:', 'Enter domain width wid:'};
dlgtitle = 'Set Workspace Size';
definput = {'10', '10'};
answer   = inputdlg(prompt, dlgtitle, [1 40], definput);

if isempty(answer)
    disp('Operation canceled. Program terminated.');
    return;
end

len = str2double(answer{1});
wid = str2double(answer{2});
if isnan(len) || isnan(wid) || len <= 0 || wid <= 0
    errordlg('len and wid must be positive numbers.', 'Parameter Error');
    return;
end

bbox  = [0 len; 0 wid];
gPoly = polyshape([bbox(1,1) bbox(1,2) bbox(1,2) bbox(1,1)], ...
                  [bbox(2,1) bbox(2,1) bbox(2,2) bbox(2,2)]);
rng('shuffle');

% ==================== UI colors ====================
bgFig     = [0.94 0.97 1.00];
bgPanel   = [0.98 0.99 1.00];
bgCard    = [1.00 1.00 1.00];
mainBlue  = [0.18 0.45 0.86];
deepBlue  = [0.10 0.27 0.55];
softGray  = [0.45 0.50 0.58];
edgeGray  = [0.78 0.82 0.88];
btnBlue   = [0.22 0.52 0.92];
btnGreen  = [0.20 0.68 0.42];
btnOrange = [0.96 0.62 0.18];
btnGray   = [0.55 0.60 0.68];

mainFont = 'Microsoft YaHei UI';
if ~ismember(mainFont, listfonts)
    mainFont = 'Arial';
end

% ==================== Main window ====================
f = figure( ...
    'Name','Interactive Voronoi Tool', ...
    'NumberTitle','off', ...
    'Color',bgFig, ...
    'Position',[180 80 1080 680], ...
    'MenuBar','none', ...
    'Toolbar','none');
movegui(f,'center');

% Header
header = uipanel(f, ...
    'Units','normalized', ...
    'Position',[0 0.91 1 0.09], ...
    'BackgroundColor',deepBlue, ...
    'BorderType','none');

uicontrol(header,'Style','text', ...
    'Units','normalized','Position',[0.02 0.38 0.50 0.40], ...
    'String','Interactive Voronoi Seed Generator', ...
    'BackgroundColor',deepBlue, ...
    'ForegroundColor','w', ...
    'FontName',mainFont, ...
    'FontSize',16, ...
    'FontWeight','bold', ...
    'HorizontalAlignment','left');

uicontrol(header,'Style','text', ...
    'Units','normalized','Position',[0.02 0.06 0.86 0.24], ...
    'String','ROI Seeding  ·  Fill Remaining  ·  Voronoi Generation  ·  Boundary Thickening', ...
    'BackgroundColor',deepBlue, ...
    'ForegroundColor',[0.88 0.93 1.00], ...
    'FontName',mainFont, ...
    'FontSize',10, ...
    'HorizontalAlignment','left');

% Left panel
panel = uipanel(f, ...
    'Units','normalized', ...
    'Position',[0.015 0.035 0.19 0.86], ...
    'Title','Control Panel', ...
    'FontName',mainFont, ...
    'FontSize',11, ...
    'FontWeight','bold', ...
    'BackgroundColor',bgPanel, ...
    'ForegroundColor',[0.15 0.18 0.22]);

btnLabels = {'Rectangle','Circle','Ellipse','Annulus','Fill Remaining','Undo','Finish'};
btnColors = {btnBlue, btnBlue, btnBlue, btnBlue, btnOrange, btnGray, btnGreen};

for i = 1:numel(btnLabels)
    y0 = 0.86 - (i-1)*0.11;
    uicontrol(panel,'Style','pushbutton','String',btnLabels{i}, ...
        'Units','normalized', ...
        'FontName',mainFont, ...
        'FontSize',10.5, ...
        'FontWeight','bold', ...
        'ForegroundColor','w', ...
        'BackgroundColor',btnColors{i}, ...
        'Position',[0.10 y0 0.80 0.075], ...
        'Callback',@(~,~)setAction(btnLabels{i}));
end

% Workspace information
infoPanel1 = uipanel(panel, ...
    'Units','normalized', ...
    'Position',[0.06 0.18 0.88 0.12], ...
    'BackgroundColor',bgCard, ...
    'BorderType','line', ...
    'HighlightColor',edgeGray, ...
    'ShadowColor',edgeGray, ...
    'Title','Workspace Info', ...
    'FontName',mainFont, ...
    'FontSize',9.5, ...
    'FontWeight','bold');

uicontrol(infoPanel1,'Style','text', ...
    'Units','normalized','Position',[0.06 0.12 0.88 0.60], ...
    'String',sprintf('len = %.4g    wid = %.4g', len, wid), ...
    'BackgroundColor',bgCard, ...
    'ForegroundColor',[0.15 0.18 0.22], ...
    'FontName',mainFont, ...
    'FontSize',10.5, ...
    'HorizontalAlignment','left');

% Point number information
infoPanel2 = uipanel(panel, ...
    'Units','normalized', ...
    'Position',[0.06 0.08 0.88 0.08], ...
    'BackgroundColor',bgCard, ...
    'BorderType','line', ...
    'HighlightColor',edgeGray, ...
    'ShadowColor',edgeGray);

txtPointNum = uicontrol(infoPanel2, 'Style', 'text', ...
    'Units', 'normalized', 'Position', [0.06 0.18 0.88 0.64], ...
    'String', 'Current points: 0', ...
    'FontName', mainFont, ...
    'FontSize', 11, ...
    'FontWeight', 'bold', ...
    'ForegroundColor', mainBlue, ...
    'BackgroundColor', bgCard, ...
    'HorizontalAlignment', 'left');

% Author information
infoPanel3 = uipanel(panel, ...
    'Units','normalized', ...
    'Position',[0.06 0.005 0.88 0.065], ...
    'BackgroundColor',bgCard, ...
    'BorderType','line', ...
    'HighlightColor',edgeGray, ...
    'ShadowColor',edgeGray);

uicontrol(infoPanel3,'Style','text', ...
    'Units','normalized','Position',[0.04 0.46 0.92 0.38], ...
    'String','author: SDU-hyc', ...
    'BackgroundColor',bgCard, ...
    'ForegroundColor',softGray, ...
    'FontName',mainFont, ...
    'FontSize',8.8, ...
    'FontAngle','italic', ...
    'HorizontalAlignment','left');

uicontrol(infoPanel3,'Style','text', ...
    'Units','normalized','Position',[0.04 0.04 0.92 0.38], ...
    'String','email: 202437682@mail.sdu.edu.cn', ...
    'BackgroundColor',bgCard, ...
    'ForegroundColor',softGray, ...
    'FontName',mainFont, ...
    'FontSize',8.8, ...
    'HorizontalAlignment','left');

% Axes
ax = axes('Parent',f,'Position',[0.24 0.11 0.73 0.76], ...
    'FontName',mainFont, ...
    'FontSize',10, ...
    'Color',[0.99 0.995 1.00], ...
    'Box','on', ...
    'LineWidth',1.1, ...
    'XColor',[0.15 0.18 0.22], ...
    'YColor',[0.15 0.18 0.22]);

drawMainAxes();

uicontrol(f,'Style','text', ...
    'Units','normalized','Position',[0.22 0.025 0.76 0.055], ...
    'String','Free academic tool. Please cite: https://doi.org/10.1016/j.jmrt.2026.01.083', ...
    'BackgroundColor',bgFig, ...
    'ForegroundColor',softGray, ...
    'FontName',mainFont, ...
    'FontSize',10, ...
    'HorizontalAlignment','left');

% ==================== Data pool ====================
xAll = [];
yAll = [];
unionPoly = polyshape;
roiHist = {};

updatePointNum();

while ishandle(f)
    drawnow;
    if isempty(actionFlag)
        pause(0.08);
        continue;
    end

    action = actionFlag;
    actionFlag = '';

    if strcmp(action,'Finish')
        break;
    end

    if strcmp(action,'Undo')
        if isempty(roiHist)
            warndlg('No operation to undo.');
            continue;
        end

        last = roiHist{end};
        roiHist(end) = [];
        xAll(last.pointIdx) = [];
        yAll(last.pointIdx) = [];
        unionPoly = last.prevUnion;

        redrawMainAxesWithPoints();
        updatePointNum();
        continue;
    end

    if strcmp(action,'Fill Remaining')
        remainPoly = subtract(gPoly,unionPoly);
        if isempty(remainPoly.Vertices)
            warndlg('No remaining area.');
            continue;
        end

        Aroi = area(remainPoly);
        [N, d, ok] = askScatterParams(Aroi, 2000);
        if ~ok
            continue;
        end

        [x, y] = generatePoints(N, d, 'poly', remainPoly);
        if isempty(x)
            warndlg('Filling failed.');
            continue;
        end

        margin = d/2;
        [x, y, nMove] = movePointsAwayFromBoundary(remainPoly, x, y, margin);
        if nMove > 0
            msgbox(sprintf('%d near-boundary points were adjusted.', nMove), 'Notice');
        end

        plot(ax, remainPoly, 'FaceColor', 'none', 'EdgeColor', [.35 .35 .35], ...
            'LineStyle', ':', 'LineWidth',1.0);
        plot(ax, x, y, '.', 'Color', [.60 .30 .70], 'MarkerSize', 9);

        xAll = [xAll; x];
        yAll = [yAll; y];

        prevUnion = unionPoly;
        unionPoly = union(unionPoly, remainPoly);

        roiHist{end+1} = struct('prevUnion', prevUnion, ...
            'pointIdx', numel(xAll)-numel(x)+1:numel(xAll));

        updatePointNum();
        continue;
    end

    % ==================== Create ROI ====================
    how = questdlg(['How to create ',action,'?'],'Drawing Mode', ...
                   'Draw','Input','Cancel','Draw');
    if isempty(how) || strcmp(how,'Cancel')
        continue;
    end

    newPoly = polyshape;

    if strcmp(how,'Input')
        switch action
            case 'Rectangle'
                a = inputdlg({'Lower-left x','Lower-left y','Width w','Height h'}, ...
                             'Rectangle Parameters',1,{'1','1','2','2'});
                if isempty(a), continue; end
                x0 = str2double(a{1}); y0 = str2double(a{2});
                w  = str2double(a{3}); h  = str2double(a{4});
                newPoly = polyshape([x0 x0+w x0+w x0], [y0 y0 y0+h y0+h]);

            case 'Circle'
                a = inputdlg({'Center x','Center y','Radius R'}, ...
                             'Circle Parameters',1,{'5','5','2'});
                if isempty(a), continue; end
                cx = str2double(a{1}); cy = str2double(a{2}); R = str2double(a{3});
                t = linspace(0,2*pi,120);
                newPoly = polyshape(cx+R*cos(t), cy+R*sin(t));

            case 'Ellipse'
                a = inputdlg({'Center x','Center y','Semi-major a','Semi-minor b','Angle (deg)'}, ...
                             'Ellipse Parameters',1,{'5','5','3','2','0'});
                if isempty(a), continue; end
                cx  = str2double(a{1}); cy = str2double(a{2});
                a1  = str2double(a{3}); b1 = str2double(a{4});
                phi = deg2rad(str2double(a{5}));
                t = linspace(0,2*pi,180);
                Rm = [cos(phi), -sin(phi); sin(phi), cos(phi)];
                pts = Rm * [a1*cos(t); b1*sin(t)];
                newPoly = polyshape(pts(1,:) + cx, pts(2,:) + cy);

            case 'Annulus'
                a = inputdlg({'Center x','Center y','Outer radius R1','Inner radius R2'}, ...
                             'Annulus Parameters',1,{'5','5','4','2'});
                if isempty(a), continue; end
                cx = str2double(a{1}); cy = str2double(a{2});
                R1 = str2double(a{3}); R2 = str2double(a{4});
                t = linspace(0,2*pi,200);
                outer = polyshape(cx+R1*cos(t), cy+R1*sin(t));
                inner = polyshape(cx+R2*cos(t), cy+R2*sin(t));
                newPoly = subtract(outer,inner);
        end
    else
        switch action
            case 'Rectangle'
                h = drawrectangle('Parent',ax, ...
                    'Color',[0.86 0.18 0.18], ...
                    'FaceAlpha',0.04, ...
                    'LineWidth',1.3, ...
                    'DrawingArea',[bbox(1,1) bbox(2,1) len wid]);
                if ~isvalid(h), continue; end

                customWaitROI(h);
                if ~isvalid(h), continue; end

                pos = h.Position;
                delete(h);

                newPoly = polyshape([pos(1) pos(1)+pos(3) pos(1)+pos(3) pos(1)], ...
                                    [pos(2) pos(2) pos(2)+pos(4) pos(2)+pos(4)]);

            case 'Circle'
                h = drawcircle('Parent',ax, ...
                    'Color',[0.10 0.62 0.85], ...
                    'FaceAlpha',0.04, ...
                    'LineWidth',1.3, ...
                    'DrawingArea',[bbox(1,1) bbox(2,1) len wid]);
                if ~isvalid(h), continue; end

                customWaitROI(h);
                if ~isvalid(h), continue; end

                c = h.Center;
                R = h.Radius;
                delete(h);

                t = linspace(0,2*pi,120);
                newPoly = polyshape(c(1)+R*cos(t), c(2)+R*sin(t));

            case 'Ellipse'
                h = drawellipse('Parent',ax, ...
                    'Color',[0.20 0.72 0.42], ...
                    'FaceAlpha',0.04, ...
                    'LineWidth',1.3, ...
                    'DrawingArea',[bbox(1,1) bbox(2,1) len wid]);
                if ~isvalid(h), continue; end

                customWaitROI(h);
                if ~isvalid(h), continue; end

                verts = h.Vertices;
                delete(h);

                newPoly = polyshape(verts);

            case 'Annulus'
                warndlg('Annulus supports parameter input only.');
                continue;
        end

        newPoly = intersect(newPoly, gPoly);
        if isempty(newPoly.Vertices) || area(newPoly) <= 0
            warndlg('The drawn region is invalid or outside the workspace.');
            continue;
        end
    end

    if isempty(newPoly.Vertices) || area(newPoly) <= 0
        continue;
    end

    if area(intersect(newPoly,unionPoly)) > 0
        if strcmp(questdlg('This ROI overlaps existing regions. Continue?','Region Overlap','Yes','No','No'),'No')
            continue;
        end
    end

    idxStart = numel(xAll) + 1;
    Aroi = area(newPoly);

    while true
        [N,d,ok] = askScatterParams(Aroi,50);
        if ~ok
            break;
        end

        [x,y] = generatePoints(N,d,'poly',newPoly);
        if ~isempty(x)
            margin = d/2;
            [x, y, nMove] = movePointsAwayFromBoundary(newPoly, x, y, margin);
            if nMove > 0
                msgbox(sprintf('%d near-boundary points were adjusted.', nMove), 'Notice');
            end

            plot(ax,newPoly,'FaceColor','none','EdgeColor',[0.15 0.15 0.15],'LineWidth',1.0);
            plot(ax,x,y,'.','Color',[.45 .45 .45],'MarkerSize',8);

            xAll = [xAll; x];
            yAll = [yAll; y];
            break;
        else
            if strcmp(questdlg('Seed generation failed. Retry?','Failed','Retry','Cancel','Retry'),'Cancel')
                break;
            end
        end
    end

    idxEnd = numel(xAll);
    if idxEnd >= idxStart
        roiHist{end+1} = struct('prevUnion',unionPoly, ...
                                'pointIdx',idxStart:idxEnd);
        unionPoly = union(unionPoly,newPoly);
    end
    updatePointNum();
end

% ==================== Hide main UI after finishing ====================
if ishandle(f)
    set(f, 'Visible', 'off');
    drawnow;
end

% ==================== Generate Voronoi ====================
if isempty(xAll)
    disp('No points were generated.');
    if ishandle(f)
        close(f);
    end
    return;
end

figV = figure( ...
    'Name','Voronoi + Grain Boundary', ...
    'NumberTitle','off', ...
    'Color',bgFig, ...
    'Position',[220 100 980 680]);

axV = axes('Parent',figV,'Position',[0.08 0.10 0.86 0.82], ...
    'FontName',mainFont, ...
    'FontSize',10, ...
    'Color',[1 1 1], ...
    'Box','on', ...
    'LineWidth',1.1);
hold(axV,'on');
grid(axV,'on');
axV.GridColor = [0.86 0.90 0.95];
axV.GridAlpha = 0.9;

[vx,vy] = voronoi(xAll,yAll);

plot(axV,vx,vy,'k','LineWidth',0.8);
plot(axV,xAll,yAll,'r.','MarkerSize',8);
axis(axV,'equal');
axis(axV,[bbox(1,:) bbox(2,:)]);
title(axV,['Voronoi Diagram — Points: ',num2str(numel(xAll))], ...
    'FontName',mainFont,'FontSize',13,'FontWeight','bold');
xlabel(axV,'X','FontName',mainFont,'FontSize',11);
ylabel(axV,'Y','FontName',mainFont,'FontSize',11);

annotation(figV,'textbox',[0.73 0.93 0.25 0.04], ...
    'String','author: SDU-hyc    email: 202437682@mail.sdu.edu.cn', ...
    'EdgeColor','none', ...
    'HorizontalAlignment','right', ...
    'FontName',mainFont, ...
    'FontSize',9.5, ...
    'Color',softGray);

% ==================== Grain-boundary thickness input ====================
default_t = 0.01 * min(len, wid);

figure(figV);
drawnow;

opts = struct();
opts.WindowStyle = 'modal';
opts.Interpreter = 'none';

ansGB = inputdlg({'Enter grain-boundary thickness t (same unit as coordinates):'}, ...
                 'Grain Boundary Thickness', 1, {num2str(default_t)}, opts);

if isempty(ansGB)
    tGB = default_t;
else
    tGB = str2double(ansGB{1});
    if isnan(tGB) || tGB <= 0
        tGB = default_t;
    end
end

% ==================== Calculate and show thickened grain-boundary region ====================
segN = size(vx,2);
gbPoly = polyshape;

for i = 1:segN
    x1 = vx(1,i); y1 = vy(1,i);
    x2 = vx(2,i); y2 = vy(2,i);

    if any(isnan([x1 y1 x2 y2]))
        continue;
    end

    if hypot(x2-x1, y2-y1) < 1e-12
        continue;
    end

    gbHalf = tGB / 2;
    gb_i = polybuffer([x1 y1; x2 y2], 'lines', gbHalf, 'JointType','miter');

    if isempty(gb_i.Vertices)
        continue;
    end

    gbPoly = union(gbPoly, gb_i);
end

gbPoly = intersect(gbPoly, gPoly);

if ~isempty(gbPoly.Vertices)
    plot(axV,gbPoly, 'FaceColor',[1 0.62 0.22], 'FaceAlpha',0.35, ...
         'EdgeColor','none');
    uistack(findobj(axV,'Type','Patch'),'bottom');
    plot(axV,vx,vy,'k','LineWidth',0.8);
end

% ==================== Export ====================
answer = questdlg('Export Voronoi line segments?', 'Export Confirmation', 'Yes', 'No', 'No');
if strcmp(answer, 'Yes')
    [file, path] = uiputfile('voronoi_plot_segments.txt', 'Save File');
    if ischar(file)
        fid = fopen(fullfile(path, file), 'w');
        fprintf(fid, '%.6f %.6f\n', len, wid);
        for i = 1:size(vx, 2)
            x1 = vx(1, i); y1 = vy(1, i);
            x2 = vx(2, i); y2 = vy(2, i);
            if any(isnan([x1 y1 x2 y2]))
                continue;
            end
            fprintf(fid, '%.6f %.6f %.6f %.6f\n', x1, y1, x2, y2);
        end
        fclose(fid);
        msgbox({'Line segments exported successfully.',['File: ', fullfile(path, file)]}, 'Export Successful');
    end
end

answer2 = questdlg('Export thickened boundary polyshape?', ...
                   'Export Boundary Polyshape', 'Yes', 'No', 'Yes');
if strcmp(answer2, 'Yes')
    [file2, path2] = uiputfile('grain_boundary_poly.txt', 'Save Boundary Polyshape File');
    if ischar(file2)
        fid2 = fopen(fullfile(path2, file2), 'w');
        fprintf(fid2, '%.6f %.6f\n', len, wid);
        fprintf(fid2, '%.6f\n', tGB);
        [bx2, by2] = boundary(gbPoly);
        for ii = 1:numel(bx2)
            fprintf(fid2, '%.6f %.6f\n', bx2(ii), by2(ii));
        end
        fclose(fid2);
        msgbox({'Boundary polyshape exported successfully.',['File: ', fullfile(path2, file2)]}, 'Export Successful');
    end
end

if ishandle(f)
    close(f);
end

% =================== Internal functions ===================
    function updatePointNum()
        set(txtPointNum, 'String', ['Current points: ', num2str(numel(xAll))]);
    end

    function setAction(val)
        actionFlag = val;
    end

    function drawMainAxes()
        cla(ax);
        axis(ax,'equal');
        axis(ax,[bbox(1,:) bbox(2,:)]);
        hold(ax,'on');
        grid(ax,'on');
        ax.GridColor = [0.86 0.90 0.95];
        ax.GridAlpha = 0.9;
        plot(ax,gPoly,'FaceColor','none','EdgeColor',[.55 .60 .68], ...
            'LineStyle','--','LineWidth',1.2);
        title(ax,{'Select ROI -> Generate Seeds','Fill Remaining -> Finish -> Voronoi + Boundary View'}, ...
            'FontName',mainFont, ...
            'FontSize',13, ...
            'FontWeight','bold', ...
            'Color',[0.12 0.16 0.22]);
        xlabel(ax,'X','FontName',mainFont,'FontSize',11,'Color',[0.15 0.18 0.22]);
        ylabel(ax,'Y','FontName',mainFont,'FontSize',11,'Color',[0.15 0.18 0.22]);
    end

    function redrawMainAxesWithPoints()
        drawMainAxes();
        if ~isempty(xAll)
            plot(ax,xAll,yAll,'.','Color',[.45 .45 .45],'MarkerSize',8);
        end
    end

    function customWaitROI(h)
        if ~isvalid(h)
            return;
        end

        tipBox = annotation(f,'textbox',[0.31 0.94 0.42 0.04], ...
            'String','Double-click inside the ROI to confirm', ...
            'EdgeColor','none', ...
            'HorizontalAlignment','center', ...
            'FontName',mainFont, ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'Color',[1 1 1], ...
            'BackgroundColor',[0.15 0.35 0.75]);

        l = addlistener(h,'ROIClicked',@clickCallback);

        try
            uiwait(f);
        catch
        end

        if isgraphics(tipBox)
            delete(tipBox);
        end
        if isvalid(l)
            delete(l);
        end

        function clickCallback(~,evt)
            if strcmp(evt.SelectionType,'double')
                try
                    uiresume(f);
                catch
                end
            end
        end
    end

end


%% =======================================================================
%                        Tool Functions
% ========================================================================

function [x, y] = generatePoints(N, minDist, ~, poly)
x = [];
y = [];
maxIter = 2e5;
iter = 0;

[bx, by] = boundingbox(poly);
xmin = bx(1);
xmax = bx(2);
ymin = by(1);
ymax = by(2);

while numel(x) < N && iter < maxIter
    iter = iter + 1;
    p = [rand*(xmax-xmin)+xmin, rand*(ymax-ymin)+ymin];

    if ~isinterior(poly, p(1), p(2))
        continue;
    end

    if isempty(x) || all((x-p(1)).^2 + (y-p(2)).^2 >= minDist^2)
        x(end+1,1) = p(1); %#ok<AGROW>
        y(end+1,1) = p(2); %#ok<AGROW>
    end
end

if iter >= maxIter && numel(x) < N
    x = [];
    y = [];
end
end


function [N, d, ok] = askScatterParams(Aroi, N0)
recD  = @(n) 0.8 * sqrt(2/sqrt(3) * Aroi / n);
N     = N0;
d     = recD(N0);
ok    = false;

dlg = dialog('Name','Seeding Parameters','Resize','off','WindowStyle','modal');
dlg.Position(3:4) = [500 180];

uicontrol(dlg,'Style','text','String','Number of seeds (N):',...
    'Position',[30 110 180 24],...
    'HorizontalAlignment','left','FontSize',10);

txtN = uicontrol(dlg,'Style','edit','String',num2str(N),...
    'Position',[220 108 220 28],...
    'FontSize',11,'Callback',@updateD);

uicontrol(dlg,'Style','text','String','Minimum spacing (d):',...
    'Position',[30 70 180 24],...
    'HorizontalAlignment','left','FontSize',10);

txtD = uicontrol(dlg,'Style','edit','String',sprintf('%.4g',d),...
    'Position',[220 68 220 28],...
    'FontSize',11);

uicontrol(dlg,'Style','pushbutton','String','OK',...
    'Position',[150 20 90 30],...
    'FontSize',11,'Callback',@onOK);

uicontrol(dlg,'Style','pushbutton','String','Cancel',...
    'Position',[270 20 90 30],...
    'FontSize',11,'Callback',@(~,~)delete(dlg));

uiwait(dlg);

    function updateD(~,~)
        nVal = str2double(get(txtN,'String'));
        if isnan(nVal) || nVal <= 0
            return;
        end
        set(txtD,'String',sprintf('%.4g',recD(nVal)));
    end

    function onOK(~,~)
        Ntry = str2double(get(txtN,'String'));
        dtry = str2double(get(txtD,'String'));

        if isnan(Ntry) || Ntry <= 0
            uiwait(warndlg('N must be a positive number.','Parameter Error'));
            return;
        end
        if isnan(dtry) || dtry <= 0
            uiwait(warndlg('d must be a positive number.','Parameter Error'));
            return;
        end

        N  = Ntry;
        d  = dtry;
        ok = true;
        delete(dlg);
    end
end


function [xMoved, yMoved, nMove] = movePointsAwayFromBoundary(pg, x, y, margin)
[minDist, isInside, segA, segB, bxAll, byAll] = pointBoundaryDist2(pg, x, y);

xMoved = x;
yMoved = y;
nMove = 0;

bxValid = bxAll(~isnan(bxAll));
byValid = byAll(~isnan(byAll));

if isempty(bxValid) || isempty(byValid)
    return;
end

bboxX = max(bxValid) - min(bxValid);
bboxY = max(byValid) - min(byValid);
maxShift = 0.1 * min(bboxX, bboxY);

for i = 1:length(x)
    if isInside(i) && minDist(i) < margin
        p = [x(i), y(i)];

        dMin = Inf;
        segMin = 0;
        for j = 1:size(segA,1)
            d = point2segment(p, segA(j,:), segB(j,:));
            if d < dMin
                dMin = d;
                segMin = j;
            end
        end

        if segMin == 0
            continue;
        end

        A = segA(segMin,:);
        B = segB(segMin,:);
        v = B - A;
        nv = norm(v);
        if nv < 1e-15
            continue;
        end
        v = v / nv;
        n = [v(2), -v(1)];

        testp = p + n * 0.1;
        if ~isinterior(pg, testp(1), testp(2))
            n = -n;
        end

        shiftDist = min(margin - minDist(i), maxShift);
        xNew = x(i) + n(1) * shiftDist;
        yNew = y(i) + n(2) * shiftDist;

        if isinterior(pg, xNew, yNew)
            xMoved(i) = xNew;
            yMoved(i) = yNew;
            nMove = nMove + 1;
        end
    end
end
end


function [minDist, isInside, segA, segB, bx, by] = pointBoundaryDist2(pg, x, y)
minDist = inf(size(x));
isInside = isinterior(pg, x, y);
[bx, by] = boundary(pg);

[segA, segB] = getBoundarySegmentsFromXY(bx, by);

if isempty(segA)
    minDist(:) = 0;
    return;
end

for i = 1:numel(x)
    p = [x(i), y(i)];
    dMin = inf;
    for j = 1:size(segA,1)
        d = point2segment(p, segA(j,:), segB(j,:));
        if d < dMin
            dMin = d;
        end
    end
    minDist(i) = dMin;
end
end


function [segA, segB] = getBoundarySegmentsFromXY(bx, by)
segA = zeros(0,2);
segB = zeros(0,2);

if isempty(bx) || isempty(by)
    return;
end

isBreak = isnan(bx) | isnan(by);
startIdx = 1;
n = numel(bx);

while startIdx <= n
    while startIdx <= n && isBreak(startIdx)
        startIdx = startIdx + 1;
    end
    if startIdx > n
        break;
    end

    endIdx = startIdx;
    while endIdx <= n && ~isBreak(endIdx)
        endIdx = endIdx + 1;
    end
    endIdx = endIdx - 1;

    if endIdx - startIdx + 1 >= 2
        xx = bx(startIdx:endIdx);
        yy = by(startIdx:endIdx);

        for k = 1:numel(xx)-1
            p1 = [xx(k),   yy(k)];
            p2 = [xx(k+1), yy(k+1)];
            if any(isnan([p1 p2]))
                continue;
            end
            if norm(p2-p1) < 1e-15
                continue;
            end
            segA(end+1,:) = p1; %#ok<AGROW>
            segB(end+1,:) = p2; %#ok<AGROW>
        end
    end

    startIdx = endIdx + 2;
end
end


function d = point2segment(p, a, b)
v = b - a;
w = p - a;
c1 = dot(w, v);
c2 = dot(v, v);

if c2 < 1e-15
    d = norm(p - a);
    return;
end

if c1 <= 0
    d = norm(p - a);
elseif c2 <= c1
    d = norm(p - b);
else
    b2 = c1 / c2;
    pb = a + b2 * v;
    d = norm(p - pb);
end
end


