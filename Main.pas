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
    procedure LoadVolumeSVD( const FileName_:STring; const SizeX_,SizeY_,SizeZ_:Single; const BricX_,BricY_,BricZ_:Integer; const AnglX_,AnglY_:Single );  //Stanford volume data
    procedure LoadVolumeTUW( const FileName_:STring; const SizeX_,SizeY_,SizeZ_:Single; const AnglX_,AnglY_:Single );  //TU Wien
    procedure LoadVolumeECS( const FileName_:STring; const AnglX_,AnglY_:Single );  //ECS 277
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

     _MouseA := TPointF.Create( 0, 0 );

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

procedure TForm1.LoadVolumeSVD( const FileName_:STring; const SizeX_,SizeY_,SizeZ_:Single; const BricX_,BricY_,BricZ_:Integer; const AnglX_,AnglY_:Single );
var
   Vs :TArray<Word>;
   VsN, X, Y, Z :Integer;
begin
     with _Shaper do
     begin
          SizeX := SizeX_;
          SizeY := SizeY_;
          SizeZ := SizeZ_;

          with Grider.Texels do
          begin
               GridsX := BricX_;
               GridsY := BricY_;
               GridsZ := BricZ_;

               VsN := BricY_ * BricX_;

               SetLength( Vs, VsN );

               for Z := 0 to BricsZ do
               begin
                    with TFileStream.Create( '..\..\_DATA\Stanford volume data\' + FileName_ + ( Z + 1 ).ToString, fmOpenRead ) do
                    begin
                         Read( Vs[ 0 ], SizeOf( Word ) * VsN );

                         DisposeOf;
                    end;

                    for Y := 0 to BricsY do
                    for X := 0 to BricsX do Grids[ X, Y, Z ] := 1 - RevBytes( Vs[ BricX_ * Y + X ] ) / 4096;
               end;
          end;

          MakeModel;

          Pose := TSingleM4.RotateY( DegToRad( AnglX_ ) ) * TSingleM4.RotateX( DegToRad( AnglY_ ) );
     end;
end;

procedure TForm1.LoadVolumeTUW( const FileName_:STring; const SizeX_,SizeY_,SizeZ_:Single; const AnglX_,AnglY_:Single );
var
   BsX, BsY, BsZ :Word;
   VsN, X, Y, Z :Integer;
   Vs :TArray<Word>;
begin
     with TFileStream.Create( '..\..\_DATA\TU Wien\' + FileName_, fmOpenRead ) do
     begin
          Read( BsX, SizeOf( Word ) );
          Read( BsY, SizeOf( Word ) );
          Read( BsZ, SizeOf( Word ) );

          VsN := BsZ * BsY * BsX;

          SetLength( Vs, VsN );

          Read( Vs[ 0 ], SizeOf( Word ) * VsN );

          DisposeOf;
     end;

     with _Shaper do
     begin
          SizeX := SizeX_;
          SizeY := SizeY_;
          SizeZ := SizeZ_;

          with Grider.Texels do
          begin
               GridsX := BsX;
               GridsY := BsY;
               GridsZ := BsZ;

               for Z := 0 to BricsZ do
               for Y := 0 to BricsY do
               for X := 0 to BricsX do Grids[ X, Y, Z ] := 1 - Vs[ ( BsY * Z + Y ) * BsX + X ] / 4095;
          end;

          MakeModel;

          Pose := TSingleM4.RotateY( DegToRad( AnglX_ ) ) * TSingleM4.RotateX( DegToRad( AnglY_ ) );
     end;
end;

procedure TForm1.LoadVolumeECS( const FileName_:STring; const AnglX_,AnglY_:Single );
var
   BsX, BsY, BsZ, MsN :Integer;
   SX, SY, SZ :Single;
   VsN, X, Y, Z :Integer;
   Vs :TArray<Byte>;
begin
     with TFileStream.Create( '..\..\_DATA\ECS 277\' + FileName_, fmOpenRead ) do
     begin
          Read( BsZ, SizeOf( Integer ) );  BsZ := RevBytes( BsZ );
          Read( BsY, SizeOf( Integer ) );  BsY := RevBytes( BsY );
          Read( BsX, SizeOf( Integer ) );  BsX := RevBytes( BsX );

          Read( MsN, SizeOf( Integer ) );  MsN := RevBytes( MsN );  Assert( MsN = 0, 'MsN = ' + MsN.ToString );

          Read( SZ, SizeOf( Single ) );  SZ := RevBytes( SZ );
          Read( SY, SizeOf( Single ) );  SY := RevBytes( SY );
          Read( SX, SizeOf( Single ) );  SX := RevBytes( SX );

          VsN := BsZ * BsY * BsX;

          SetLength( Vs, VsN );

          Read( Vs[ 0 ], SizeOf( Byte ) * VsN );

          DisposeOf;
     end;

     with _Shaper do
     begin
          SizeX := SX;
          SizeY := SY;
          SizeZ := SZ;

          with Grider.Texels do
          begin
               GridsX := BsX;
               GridsY := BsY;
               GridsZ := BsZ;

               for Z := 0 to BricsZ do
               for Y := 0 to BricsY do
               for X := 0 to BricsX do Grids[ X, Y, Z ] := 1 - Vs[ ( Z * BsY + Y ) * BsX + X ] / 255;
          end;

          MakeModel;

          Pose := TSingleM4.RotateY( DegToRad( AnglX_ ) ) * TSingleM4.RotateX( DegToRad( AnglY_ ) );
     end;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

procedure TForm1.FormCreate(Sender: TObject);
begin
     _Scener := TGLScener.Create;

     MakeCamera;

     _Shaper := TMarcubes.Create( _Scener );

     ////////// Stanford volume data
       LoadVolumeSVD( 'CThead\CThead.'  , 2, 2, 2, 256, 256, 113, 180, +90 );
     //LoadVolumeSVD( 'MRbrain\MRbrain.', 2, 2, 1, 256, 256, 109, +90, 180 );
     //LoadVolumeSVD( 'bunny-ctscan\'   , 2, 2, 2, 512, 512, 360, 180, +90 );

     ////////// TU Wien
     //LoadVolumeTUW( 'present246x246x221.dat'            , 2, 2, 2, +90 , +90 );
     //LoadVolumeTUW( 'present328x328x294.dat'            , 2, 2, 2, +90 , +90 );
     //LoadVolumeTUW( 'present492x492x442.dat'            , 2, 2, 2, +90 , +90 );
     //LoadVolumeTUW( 'stagbeetle208x208x123.dat'         , 2, 2, 2, +90 , +90 );
     //LoadVolumeTUW( 'stagbeetle277x277x164.dat'         , 2, 2, 2, +90 , +90 );
     //LoadVolumeTUW( 'dataset-stagbeetle-416x416x247.dat', 2, 2, 2, +90 , +90 );
     //LoadVolumeTUW( 'stagbeetle832x832x494.dat'         , 2, 2, 2, +90 , +90 );
     //LoadVolumeTUW( 'christmastree128x124x128.dat'      , 2, 2, 2,  0  , -90 );
     //LoadVolumeTUW( 'christmastree170x166x170.dat'      , 2, 2, 2,  0  , -90 );
     //LoadVolumeTUW( 'christmastree256x249x256.dat'      , 2, 2, 2,  0  , -90 );
     //LoadVolumeTUW( 'christmastree512x499x512.dat'      , 2, 2, 2,  0  , -90 );

     ////////// ECS 277
     //LoadVolumeECS( 'Skull.vol'   ,  0 , -90 );
     //LoadVolumeECS( 'Foot.vol'    ,  0 , -90 );
     //LoadVolumeECS( 'Frog.vol'    , -90, +90 );
     //LoadVolumeECS( 'C60.vol'     ,  0 ,  0  );
     //LoadVolumeECS( 'C60Large.vol',  0 ,  0  );

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

     Caption := _Shaper.Threshold.ToString;

     GLViewer1.Repaint;
end;

//------------------------------------------------------------------------------

procedure TForm1.Button1Click(Sender: TObject);
const
     FrameN = 30{fps} * 60{s};
var
   R :TGLRender;
   I :Integer;
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

          _Shaper.Threshold := ( 0.97 - 0.43 ) * ( 1 + Sin( Pi4 * T ) ) / 2 + 0.43;

          with _Camera do
          begin
               Pose := TSingleM4.RotateY( 5 * Pi2 * T )
                     * TSingleM4.RotateX( -P4i * Sin( 3 * Pi2 * T ) )
                     * TSingleM4.Translate( 0, 0, ( 2 - 3 ) * ( 1 - Cos( Pi2 * T ) ) / 2 + 3 );
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
