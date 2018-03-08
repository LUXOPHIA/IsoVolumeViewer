unit Main;

interface //#################################################################### ■

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Math.Vectors,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.Objects, FMX.TabControl,
  LUX, LUX.D1, LUX.D2, LUX.D3, LUX.M4,
  LUX.GPU.OpenGL,
  LUX.GPU.OpenGL.Viewer,
  LUX.GPU.OpenGL.Scener,
  LUX.GPU.OpenGL.Camera,
  LUX.GPU.OpenGL.Render,
  LUX.GPU.OpenGL.Shaper.Preset.TMarcubes;

type
  TForm1 = class(TForm)
    GLViewer1: TGLViewer;
    Panel1: TPanel;
    Button1: TButton;
    ScrollBar1: TScrollBar;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure GLViewer1DblClick(Sender: TObject);
    procedure GLViewer1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure GLViewer1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure GLViewer1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure ScrollBar1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { private 宣言 }
    _MouseA :TSingle2D;
    _MouseS :TShiftState;
    _MouseP :TSingle2D;
  public
    { public 宣言 }
    _Scener :TGLScener;
    _Camera :TGLCameraPers;
    _Shaper :TMarcubes;
    ///// メソッド
    procedure MakeCamera;
    procedure MoveCamera;
    procedure LoadVoxels( const FileName_:STring; const BricX_,BricY_,BricZ_:Integer );
  end;

var
  Form1: TForm1;

implementation //############################################################### ■

{$R *.fmx}

uses System.Math;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

/////////////////////////////////////////////////////////////////////// メソッド

procedure TForm1.MakeCamera;
begin
     _Camera := TGLCameraPers.Create( _Scener );

     with _Camera do
     begin
          Angl := DegToRad( 60{°} );
     end;

     GLViewer1.Camera := _Camera;

     _MouseA := TPointF.Create( 150, -20 );

     MoveCamera;
end;

procedure TForm1.MoveCamera;
begin
     with _Camera do
     begin
          Pose := TSingleM4.RotateY( DegToRad( -_MouseA.X ) )
                * TSingleM4.RotateX( DegToRad( -_MouseA.Y ) )
                * TSingleM4.Translate( 0, 0, 2 );
     end;
end;

//------------------------------------------------------------------------------

procedure TForm1.LoadVoxels( const FileName_:STring; const BricX_,BricY_,BricZ_:Integer );
var
   X, Y, Z :Integer;
   F :TFileStream;
   Ws :TArray<Word>;
begin
     with _Shaper do
     begin
          with Grider.Texels do
          begin
               GridsX := BricX_;
               GridsY := BricY_;
               GridsZ := BricZ_;

               SetLength( Ws, GridsY * GridsX );

               for Z := 0 to BricsZ do
               begin
                    F := TFileStream.Create( FileName_ + ( Z + 1 ).ToString, fmOpenRead );

                    F.Read( Ws[ 0 ], GridsY * GridsX * SizeOf( Word ) );

                    F.DisposeOf;

                    for Y := 0 to BricsY do
                    for X := 0 to BricsX do Grids[ X, Y, Z ] := 1 - RevBytes( Ws[ GridsX * Y + X ] ) / 4096;
               end;
          end;

          MakeModel;
     end;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

procedure TForm1.FormCreate(Sender: TObject);
begin
     _Scener := TGLScener.Create;

     MakeCamera;

     _Shaper := TMarcubes.Create( _Scener );

     with _Shaper do
     begin
          SizeX := 2;
          SizeY := 2;
          SizeZ := 2;
          {
          with Matery as TMarcubesMateryFaces do
          begin
               Imager.LoadFromFile( '..\..\_DATA\Spherical_2048x1024.png' );
          end;
          }
          Pose := TSingleM4.RotateX( DegToRad( 90 ) );
     end;

     LoadVoxels( '..\..\_DATA\Stanford volume data\CThead\CThead.', 256, 256, 113 );
     //LoadVoxels( '..\..\_DATA\Stanford volume data\bunny-ctscan\', 512, 512, 360 );
     //LoadVoxels( '..\..\_DATA\Stanford volume data\MRbrain\MRbrain.', 256, 256, 109 );

     ScrollBar1Change( Sender );
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
     _Scener.DisposeOf;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.GLViewer1DblClick(Sender: TObject);
begin
     with GLViewer1.MakeScreenShot do
     begin
          SaveToFile( 'Viewer1.png' );

          DisposeOF;
     end;
end;

//------------------------------------------------------------------------------

procedure TForm1.GLViewer1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
     _MouseS := Shift;
     _MouseP := TSingle2D.Create( X, Y );
end;

procedure TForm1.GLViewer1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
   P :TSingle2D;
begin
     if ssLeft in _MouseS then
     begin
          P := TSingle2D.Create( X, Y );

          _MouseA := _MouseA + ( P - _MouseP );

          MoveCamera;

          GLViewer1.Repaint;

          _MouseP := P;
     end;
end;

procedure TForm1.GLViewer1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
     GLViewer1MouseMove( Sender, Shift, X, Y );

     _MouseS := [];
end;

//------------------------------------------------------------------------------

procedure TForm1.ScrollBar1Change(Sender: TObject);
begin
     _Shaper.Threshold := 1 - ScrollBar1.Value;

     GLViewer1.Repaint;
end;

//------------------------------------------------------------------------------

procedure TForm1.Button1Click(Sender: TObject);
const
     FrameN = 30{fps} * 60{s};
var
   R :TGLRender;
   I, N :Integer;
   T :SIngle;
begin
     R := TGLRender.Create;

     with R do
     begin
          SizeX := 1920;
          SizeY := 1080;

          Camera := _Camera;
     end;

     for I := 0 to FrameN do
     begin
          T := ( 1 - Cos( Pi / FrameN * I ) ) / 2;

          N := Round( Power( 2, ( 8 - 4 ) * ( 1 - Cos( P2i * 5 * T ) ) / 2 + 4 ) );

          _Shaper.LineS := 16 / N;

          with _Shaper.Grider.Texels do
          begin
               BricsX := N;
               BricsY := N;
               BricsZ := N;
          end;

          with _Camera do
          begin
               Pose := TSingleM4.RotateY( 5 * Pi2 * T )
                     * TSingleM4.RotateX( -P4i * Sin( 3 * Pi2 * T ) )
                     * TSingleM4.Translate( 0, 0, ( 1 - 3 ) * ( 1 - Cos( Pi2 * T ) ) / 2 + 3 );
          end;

          with R do
          begin
               Render;

               with MakeScreenShot do
               begin
                    SaveToFile( 'X:\_FRAMES\' + 'IsoVolumeViewer' + I.ToString + '.bmp' );

                    DisposeOF;
               end;
          end;
     end;

     R.DisposeOf;
end;

end. //######################################################################### ■
