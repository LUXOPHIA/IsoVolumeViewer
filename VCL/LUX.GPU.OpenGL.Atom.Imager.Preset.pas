unit LUX.GPU.OpenGL.Atom.Imager.Preset;

interface //#################################################################### ■

uses System.UITypes,
     Vcl.Graphics,
     LUX,
     LUX.GPU.OpenGL.Atom.Imager.D1,
     LUX.GPU.OpenGL.Atom.Imager.D2,
     LUX.GPU.OpenGL.Atom.Imager.D3;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TGLImager1D_TAlphaColorF

     TGLImager1D_TAlphaColorF = class( TGLBricer1D<TAlphaColorF> )
     private
     protected
     public
       constructor Create;
       destructor Destroy; override;
       ///// メソッド
       procedure ImportFrom( const BMP_:TBitmap );
       procedure ExportTo( const BMP_:TBitmap );
       procedure LoadFromFile( const FileName_:String );
       procedure SaveToFile( const FileName_:String );
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TGLImager2D_TAlphaColorF

     TGLImager2D_TAlphaColorF = class( TGLBricer2D<TAlphaColorF> )
     private
     protected
     public
       constructor Create;
       destructor Destroy; override;
       ///// メソッド
       procedure ImportFrom( const BMP_:TBitmap );
       procedure ExportTo( const BMP_:TBitmap );
       procedure LoadFromFile( const FileName_:String );
       procedure SaveToFile( const FileName_:String );
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TGLImager3D_TAlphaColorF

     TGLImager3D_TAlphaColorF = class( TGLBricer3D<TAlphaColorF> )
     private
     protected
     public
       constructor Create;
       destructor Destroy; override;
     end;

//const //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

//var //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

implementation //############################################################### ■

uses Winapi.OpenGL, Winapi.OpenGLext;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TGLImager1D_TAlphaColorF

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TGLImager1D_TAlphaColorF.Create;
begin
     inherited;

     _TexelF := GL_RGBA;
     _PixelF := GL_RGBA;
     _PixelT := GL_FLOAT;
end;

destructor TGLImager1D_TAlphaColorF.Destroy;
begin

     inherited;
end;

/////////////////////////////////////////////////////////////////////// メソッド

procedure TGLImager1D_TAlphaColorF.ImportFrom( const BMP_:TBitmap );
var
   X :Integer;
   C :TAlphaColorF;
begin
     Texels.BricsX := BMP_.Width;

     for X := 0 to Texels.BricsX-1 do
     begin
          with TColorRec( BMP_.Canvas.Pixels[ X, 0 ] ) do
          begin
               C.R := R / 255;
               C.G := G / 255;
               C.B := B / 255;
               C.A := 1      ;
          end;

          Texels[ X ] := C;
     end;

     SendData;
end;

procedure TGLImager1D_TAlphaColorF.ExportTo( const BMP_:TBitmap );
var
   X :Integer;
begin
     BMP_.SetSize( Texels.BricsX, 1 );

     for X := 0 to Texels.BricsX-1 do
     begin
          BMP_.Canvas.Pixels[ X, 0 ] := Texels[ X ].ToAlphaColor;
     end;
end;

//------------------------------------------------------------------------------

procedure TGLImager1D_TAlphaColorF.LoadFromFile( const FileName_:String );
var
   B :TBitmap;
begin
     B := TBitmap.Create;

     B.LoadFromFile( FileName_ );

     ImportFrom( B );

     B.DisposeOf;
end;

procedure TGLImager1D_TAlphaColorF.SaveToFile( const FileName_:String );
var
   B :TBitmap;
begin
     B := TBitmap.Create;

     ExportTo( B );

     B.SaveToFile( FileName_ );

     B.DisposeOf;
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TGLImager2D_TAlphaColorF

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TGLImager2D_TAlphaColorF.Create;
begin
     inherited;

     _TexelF := GL_RGBA;
     _PixelF := GL_RGBA;
     _PixelT := GL_FLOAT;
end;

destructor TGLImager2D_TAlphaColorF.Destroy;
begin

     inherited;
end;

/////////////////////////////////////////////////////////////////////// メソッド

procedure TGLImager2D_TAlphaColorF.ImportFrom( const BMP_:TBitmap );
var
   X, Y :Integer;
   C :TAlphaColorF;
begin
     Texels.BricsX := BMP_.Width ;
     Texels.BricsY := BMP_.Height;

     for Y := 0 to Texels.BricsY-1 do
     begin
          for X := 0 to Texels.BricsX-1 do
          begin
               with TColorRec( BMP_.Canvas.Pixels[ X, Y ] ) do
               begin
                    C.R := R / 255;
                    C.G := G / 255;
                    C.B := B / 255;
                    C.A := 1      ;
               end;

               Texels[ X, Y ] := C;
          end;
     end;

     SendData;
end;

procedure TGLImager2D_TAlphaColorF.ExportTo( const BMP_:TBitmap );
var
   X, Y :Integer;
begin
     BMP_.SetSize( Texels.BricsX, Texels.BricsY );

     for Y := 0 to Texels.BricsY-1 do
     begin
          for X := 0 to Texels.BricsX-1 do
          begin
               BMP_.Canvas.Pixels[ X, Y ] := Texels[ X, Y ].ToAlphaColor;
          end;
     end;
end;

//------------------------------------------------------------------------------

procedure TGLImager2D_TAlphaColorF.LoadFromFile( const FileName_:String );
var
   B :TBitmap;
begin
     B := TBitmap.Create;

     B.LoadFromFile( FileName_ );

     ImportFrom( B );

     B.DisposeOf;
end;

procedure TGLImager2D_TAlphaColorF.SaveToFile( const FileName_:String );
var
   B :TBitmap;
begin
     B := TBitmap.Create;

     ExportTo( B );

     B.SaveToFile( FileName_ );

     B.DisposeOf;
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TGLImager3D_TAlphaColorF

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TGLImager3D_TAlphaColorF.Create;
begin
     inherited;

     _TexelF := GL_RGBA;
     _PixelF := GL_RGBA;
     _PixelT := GL_FLOAT;
end;

destructor TGLImager3D_TAlphaColorF.Destroy;
begin

     inherited;
end;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

//############################################################################## □

initialization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 初期化

finalization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 最終化

end. //######################################################################### ■