from django.shortcuts import render
from django.db import connection
from django.shortcuts import render, redirect
from datetime import datetime
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import calendar
import json


def login_usuario(request):

    if request.method == 'POST':

        correo = request.POST['correo']
        password = request.POST['password']

        with connection.cursor() as cursor:

            query = """
                SELECT nombreUsuario
                FROM Usuarios.Usuario
                WHERE correoUsuario = %s
                AND contraseñaUsuario = %s
            """

            cursor.execute(query, [correo, password])

            usuario = cursor.fetchone()

            if usuario:

                request.session['usuario_nombre'] = usuario[0]
                return redirect('/dashboard-usuario/')

            else:

                return render(request, 'viveec/login_usuario.html', {
                    'error': 'Correo o contraseña incorrectos'
                })

    return render(request, 'viveec/login_usuario.html')



def login_artista(request):

    if request.method == 'POST':

        correo = request.POST['correo']
        password = request.POST['password']

        with connection.cursor() as cursor:

            query = """
                SELECT nombreArtista
                FROM Musica.Artista
                WHERE correoArtista = %s
                AND contraseñaArtista = %s
            """

            cursor.execute(query, [correo, password])

            artista = cursor.fetchone()

            if artista:

                request.session['artista_nombre'] = artista[0]
                return redirect('/dashboard-artista/')

            else:

                return render(request, 'viveec/login_artista.html', {
                    'error': 'Correo o contraseña incorrectos'
                })

    return render(request, 'viveec/login_artista.html')


def registro_usuario(request):
    if request.method == 'POST':
        nombre = request.POST['nombre']
        correo = request.POST['correo']
        password = request.POST['password']
        pais = request.POST['pais']  

        with connection.cursor() as cursor:
            
            cursor.execute("SELECT correoUsuario FROM Usuarios.Usuario WHERE correoUsuario = %s", [correo])
            if cursor.fetchone():
                return render(request, 'viveec/registro_usuario.html', {
                    'error': 'El correo ya se encuentra registrado'
                })

            
            cursor.execute("SELECT TOP 1 IdUsuario FROM Usuarios.Usuario ORDER BY IdUsuario DESC")
            resultado = cursor.fetchone()
            ultimo_id = resultado[0] if resultado else 'U000'
            numero = int(ultimo_id[1:])
            nuevo_id = f'U{numero + 1:03}'

            query = """
                INSERT INTO Usuarios.Usuario (IdUsuario, correoUsuario, contraseñaUsuario, nombreUsuario, pais)
                VALUES (%s, %s, %s, %s, %s)
            """
            cursor.execute(query, [nuevo_id, correo, password, nombre, pais])

        return render(request, 'viveec/registro_usuario.html', {'registro_exitoso': True})

    return render(request, 'viveec/registro_usuario.html')


def registro_artista(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT idDiscografica, nombreDiscografica FROM Musica.Discografica")
        discograficas = cursor.fetchall()

    if request.method == 'POST':
        nombre = request.POST['nombre']
        correo = request.POST['correo']
        password = request.POST['password']
        discografica = request.POST['discografica'] or None
        
        with connection.cursor() as cursor:
            
            cursor.execute("SELECT correoArtista FROM Musica.Artista WHERE correoArtista = %s", [correo])
            if cursor.fetchone():
                return render(request, 'viveec/registro_artista.html', {
                    'error': 'El correo ya se encuentra registrado',
                    'discograficas': discograficas
                })

            
            cursor.execute("SELECT TOP 1 idArtista FROM Musica.Artista ORDER BY idArtista DESC")
            ultimo_id = cursor.fetchone()[0]
            nuevo_id = f'A{int(ultimo_id[1:]) + 1:03}'

            query = """
                INSERT INTO Musica.Artista (idArtista, nombreArtista, correoArtista, contraseñaArtista, idDiscografica)
                VALUES (%s, %s, %s, %s, %s)
            """
            cursor.execute(query, [nuevo_id, nombre, correo, password, discografica])

        return render(request, 'viveec/registro_artista.html', {
            'registro_exitoso': True, 'discograficas': discograficas
        })

    return render(request, 'viveec/registro_artista.html', {'discograficas': discograficas})


def dashboard_usuario(request):
    nombre_usuario = request.session.get('usuario_nombre')
    
    if not nombre_usuario:
        return redirect('/login-usuario/')

    id_usuario = None
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT IdUsuario 
            FROM Usuarios.Usuario 
            WHERE nombreUsuario = %s
        """, [nombre_usuario])
        res = cursor.fetchone()
        if res:
            id_usuario = res[0]

    if not id_usuario:
        return redirect('/login-usuario/')

    recomendaciones = []
    albumes_guardados = []
    artistas_favoritos = []

    with connection.cursor() as cursor:
        try:
            cursor.execute("EXEC dbo.SP_Redomendaciones @IdUsuario = %s", [id_usuario])
            filas_sp = cursor.fetchall()
            
            for fila in filas_sp:
                nombre_cancion_sp = fila[0]
                genero_sp = fila[1]
                artista_sp = fila[2]
                
                query_completo = """
                    SELECT TOP 1 
                        MC.idCancion, 
                        MA.idArtista
                    FROM Musica.Cancion MC
                    INNER JOIN Musica.Album MB ON MC.idAlbum = MB.idAlbum
                    INNER JOIN Musica.Artista MA ON MB.idArtista = MA.idArtista
                    WHERE MC.nombreCancion = %s
                """
                cursor.execute(query_completo, [nombre_cancion_sp])
                res_completo = cursor.fetchone()
                
                if res_completo:
                    id_cancion_real = res_completo[0]
                    id_artista_real = res_completo[1]
                else:
                    id_cancion_real = ""
                    id_artista_real = ""

                recomendaciones.append({
                    'idCancion': id_cancion_real,
                    'Recomendacion': nombre_cancion_sp,
                    'Genero': genero_sp,
                    'Artista': artista_sp,
                    'idArtista': id_artista_real
                })
        except Exception as e:
            print(f"Error en recomendaciones: {e}")
            recomendaciones = []

        try:
            cursor.execute("EXEC dbo.SP_AlbumesGuardados @IdUsuario = %s", [id_usuario])
            filas_albumes = cursor.fetchall()
            
            for fila in filas_albumes:
                albumes_guardados.append({
                    'id_album': fila[0],
                    'nombre_album': fila[1],
                    'artista': fila[2]
                })
        except Exception as e:
            print(f"Error en álbumes guardados: {e}")
            albumes_guardados = []

        try:
            cursor.execute("EXEC dbo.SP_ArtistasSeguidos @IdUsuario = %s", [id_usuario])
            filas_artistas = cursor.fetchall()
            
            for fila in filas_artistas:
                artistas_favoritos.append({
                    'id_artista': fila[0],
                    'nombre_artista': fila[1]
                })
        except Exception as e:
            print(f"Error en artistas seguidos: {e}")
            artistas_favoritos = []

    return render(request, 'viveec/dashboard_usuario.html', {
        'nombre': nombre_usuario,
        'recomendaciones': recomendaciones,
        'albumes': albumes_guardados,
        'artistas': artistas_favoritos
    })

def dashboard_artista(request):
    nombre_artista = request.session.get('artista_nombre')
    
    id_artista = None
    with connection.cursor() as cursor:
        cursor.execute("SELECT idArtista FROM Musica.Artista WHERE nombreArtista = %s", [nombre_artista])
        res = cursor.fetchone()
        if res:
            id_artista = res[0]

    if not id_artista:
        return redirect('/login-artista/')

    total_seguidores = 0
    total_albumes = 0
    total_canciones = 0

    with connection.cursor() as cursor:
        try:
            cursor.execute("SELECT COUNT(*) FROM Usuarios.SeguimientoArtistas WHERE idArtista = %s", [id_artista])
            res_seg = cursor.fetchone()
            if res_seg:
                total_seguidores = res_seg[0]
        except Exception:
            total_seguidores = 0 

        cursor.execute("SELECT COUNT(*) FROM Musica.Album WHERE idArtista = %s", [id_artista])
        res_alb = cursor.fetchone()
        if res_alb:
            total_albumes = res_alb[0]

        query_canciones = """
            SELECT COUNT(MC.idCancion) 
            FROM Musica.Cancion MC
            INNER JOIN Musica.Album MA ON MC.idAlbum = MA.idAlbum
            WHERE MA.idArtista = %s
        """
        cursor.execute(query_canciones, [id_artista])
        res_can = cursor.fetchone()
        if res_can:
            total_canciones = res_can[0]

    return render(request, 'viveec/dashboard_artista.html', {
        'nombre': nombre_artista,
        'total_seguidores': total_seguidores,
        'total_albumes': total_albumes,
        'total_canciones': total_canciones
    })


def gestion_albumes(request):
    nombre_artista = request.session.get('artista_nombre')
    if not nombre_artista:
        return redirect('/login-artista/')

    error_formulario = None

    if request.method == 'POST':
        accion = request.POST.get('accion')

        if accion == 'agregar':
            nombre_album = request.POST.get('nombreAlbum')
            fecha = request.POST.get('fechaLanzamiento')

            with connection.cursor() as cursor:
                cursor.execute("SELECT TOP 1 idAlbum FROM Musica.Album ORDER BY idAlbum DESC")
                resultado_id = cursor.fetchone()

                if resultado_id:
                    ultimo_id = resultado_id[0]
                    numero = int(ultimo_id[2:])  
                    nuevo_numero = numero + 1
                    nuevo_id = f'AL{nuevo_numero:02}' 
                else:
                    nuevo_id = 'AL01'  

                cursor.execute("EXEC dbo.SP_InsertarAlbum %s, %s, %s, %s", 
                               [nuevo_id, nombre_album, fecha, nombre_artista])
                
                if cursor.description:
                    resultado_sp = cursor.fetchone()
                    if resultado_sp:
                        error_formulario = resultado_sp[1] 
                else:
                    return redirect('/gestion-albumes/')

        elif accion == 'editar':
            id_album = request.POST.get('idAlbum')
            nombre_album = request.POST.get('nombreAlbum')
            fecha = request.POST.get('fechaLanzamiento')

            with connection.cursor() as cursor:
                cursor.execute("EXEC dbo.SP_ActualizarAlbum %s, %s, %s", 
                               [id_album, nombre_album, fecha])
                
                if cursor.description:
                    resultado_sp = cursor.fetchone()
                    if resultado_sp:
                        error_formulario = resultado_sp[1]
                else:
                    return redirect('/gestion-albumes/')

        elif accion == 'eliminar':
            id_album = request.POST.get('idAlbum')

            with connection.cursor() as cursor:
                cursor.execute("EXEC dbo.SP_EliminarAlbum %s", [id_album])
                
                if cursor.description:
                    resultado_sp = cursor.fetchone()
                    if resultado_sp:
                        error_formulario = resultado_sp[1] 
                else:
                    return redirect('/gestion-albumes/')

    albumes = []
    with connection.cursor() as cursor:
        query_listado = """
            SELECT 
                idAlbum, 
                nombreAlbum, 
                YEAR(fechaLanzamientoAlbum) AS anio_album,
                (SELECT COUNT(*) FROM Musica.Cancion C WHERE C.idAlbum = vListadoDeAlbumes.idAlbum) AS total_canciones,
                CONVERT(VARCHAR(10), fechaLanzamientoAlbum, 23) AS fecha_completa
            FROM dbo.vListadoDeAlbumes
            WHERE nombreArtista = %s
        """
        cursor.execute(query_listado, [nombre_artista])
        albumes = cursor.fetchall()

    return render(request, 'viveec/gestion_albumes.html', {
        'albumes': albumes,
        'nombre': nombre_artista,
        'error_formulario': error_formulario
    })

def gestion_canciones(request, id_album):
    nombre_artista = request.session.get('artista_nombre')
    if not nombre_artista:
        return redirect('/login-artista/')

    error_formulario = None

    generos_disponibles = []
    with connection.cursor() as cursor:
        cursor.execute("SELECT idGenero, nombreGenero FROM Musica.Genero ORDER BY nombreGenero ASC")
        generos_disponibles = cursor.fetchall()

        query_album = "SELECT nombreAlbum, YEAR(fechaLanzamientoAlbum) FROM Musica.Album WHERE idAlbum = %s"
        cursor.execute(query_album, [id_album])
        info_album = cursor.fetchone()
    
    nombre_album = info_album[0] if info_album else ""

    if request.method == 'POST':
        accion = request.POST.get('accion')

        if accion == 'agregar':
            nombre = request.POST.get('nombre')
            duracion = int(request.POST.get('duracion', 0))
            fecha = request.POST.get('fechaLanzamiento')
            calidad = request.POST.get('calidad')
            estado = request.POST.get('estado')
            id_genero = request.POST.get('genero') 

            with connection.cursor() as cursor:
                cursor.execute("SELECT TOP 1 idCancion FROM Musica.Cancion ORDER BY idCancion DESC")
                resultado_id = cursor.fetchone()

                if resultado_id:
                    ultimo_id = resultado_id[0]
                    numero = int(ultimo_id[1:])
                    nuevo_numero = numero + 1
                    nuevo_id = f'C{nuevo_numero:03}'
                else:
                    nuevo_id = 'C001'

                cursor.execute("EXEC dbo.SP_InsertarCancion %s, %s, %s, %s, %s, %s, %s", 
                               [nuevo_id, nombre, duracion, fecha, calidad, estado, nombre_album])
                
                if cursor.description: 
                    resultado_sp = cursor.fetchone()
                    if resultado_sp:
                        error_formulario = resultado_sp[1] 
                else:
                    if id_genero:
                        cursor.execute(
                            "INSERT INTO Musica.CancionGenero (idCancion, idGenero) VALUES (%s, %s)",
                            [nuevo_id, id_genero]
                        )
                    return redirect(f'/gestion-canciones/{id_album}/')

        elif accion == 'editar':
            id_cancion = request.POST.get('idCancion')
            nombre = request.POST.get('nombre')
            duracion = int(request.POST.get('duracion', 0))
            fecha = request.POST.get('fechaLanzamiento')
            calidad = request.POST.get('calidad')
            estado = request.POST.get('estado')
            id_genero = request.POST.get('genero') 

            with connection.cursor() as cursor:
                cursor.execute("EXEC dbo.SP_ActualizarCancion %s, %s, %s, %s, %s, %s, %s", 
                               [id_cancion, nombre, duracion, fecha, calidad, estado, nombre_album])
                
                if cursor.description:
                    resultado = cursor.fetchone()
                    if resultado:
                        error_formulario = resultado[1]
                else:
                    if id_genero:
                        cursor.execute("DELETE FROM Musica.CancionGenero WHERE idCancion = %s", [id_cancion])
                        
                        cursor.execute(
                            "INSERT INTO Musica.CancionGenero (idCancion, idGenero) VALUES (%s, %s)",
                            [id_cancion, id_genero]
                        )
                    return redirect(f'/gestion-canciones/{id_album}/')

        elif accion == 'eliminar':
            id_cancion = request.POST.get('idCancion')

            with connection.cursor() as cursor:
                cursor.execute("DELETE FROM Musica.CancionGenero WHERE idCancion = %s", [id_cancion])
                
                cursor.execute("EXEC dbo.SP_EliminarCancion %s", [id_cancion])
                
                if cursor.description:
                    resultado = cursor.fetchone()
                    if resultado:
                        error_formulario = resultado[1]
                else:
                    return redirect(f'/gestion-canciones/{id_album}/')

    canciones = []
    with connection.cursor() as cursor:
        query_canciones = """
            SELECT 
                C.idCancion, 
                C.nombreCancion, 
                (SELECT COUNT(*) FROM Operaciones.ReproduccionCancion R WHERE R.idCancion = C.idCancion) AS reproducciones,
                RIGHT('0' + CAST(C.duracionCancion / 60 AS VARCHAR), 2) + ':' + 
                RIGHT('0' + CAST(C.duracionCancion - (C.duracionCancion / 60 * 60) AS VARCHAR), 2) AS formato_duracion,
                C.calidadAudio, 
                C.estadoCancion,
                C.duracionCancion,
                CONVERT(VARCHAR(10), C.fechaLanzamientoCancion, 23) AS fecha_formato,
                (SELECT TOP 1 CG.idGenero FROM Musica.CancionGenero CG WHERE CG.idCancion = C.idCancion) AS idGenero,
                ISNULL((SELECT TOP 1 G.nombreGenero FROM Musica.CancionGenero CG 
                        INNER JOIN Musica.Genero G ON CG.idGenero = G.idGenero 
                        WHERE CG.idCancion = C.idCancion), 'Sin Género') AS nombreGenero
            FROM Musica.Cancion C
            WHERE C.idAlbum = %s
        """
        cursor.execute(query_canciones, [id_album])
        canciones = cursor.fetchall()

    return render(request, 'viveec/gestion_canciones.html', {
        'canciones': canciones,
        'info_album': info_album,
        'id_album': id_album,
        'nombre': nombre_artista,
        'error_formulario': error_formulario,
        'generos_disponibles': generos_disponibles 
    })

def regalias_artista(request):
    nombre_artista = request.session.get('artista_nombre')
    
    id_artista = None
    with connection.cursor() as cursor:
        cursor.execute("SELECT idArtista FROM Musica.Artista WHERE nombreArtista = %s", [nombre_artista])
        res = cursor.fetchone()
        if res:
            id_artista = res[0]

    if not id_artista:
        return redirect('/login-artista/')

    error_formulario = None
    mensaje_exito = None

    hoy = datetime.now()
    fecha_inicio_mes = hoy.replace(day=1).strftime('%Y-%m-%d')
    ultimo_dia = calendar.monthrange(hoy.year, hoy.month)[1]
    fecha_fin_mes = hoy.replace(day=ultimo_dia).strftime('%Y-%m-%d')

    with connection.cursor() as cursor:
        query_buscar = """
            SELECT idRegalia 
            FROM Operaciones.Regalia 
            WHERE idArtista = %s 
              AND (
                  %s BETWEEN fechaInicio AND fechaFin
                  OR %s BETWEEN fechaInicio AND fechaFin
              )
        """
        cursor.execute(query_buscar, [id_artista, fecha_inicio_mes, fecha_fin_mes])
        registro_existente = cursor.fetchone()

        if registro_existente:
            nuevo_id = registro_existente[0]
            cursor.execute("DELETE FROM Operaciones.Regalia WHERE idRegalia = %s", [nuevo_id])
        else:
            cursor.execute("SELECT TOP 1 idRegalia FROM Operaciones.Regalia ORDER BY idRegalia DESC")
            ultimo_id_res = cursor.fetchone()
            if ultimo_id_res:
                ultimo_id = ultimo_id_res[0]
                numero = int(ultimo_id[1:])
                nuevo_id = f'R{numero + 1:03}'
            else:
                nuevo_id = 'R001'

        try:
            cursor.execute("EXEC dbo.SP_GenerarRegalias %s, %s, %s, %s", 
                           [nuevo_id, id_artista, fecha_inicio_mes, fecha_fin_mes])
            
            if cursor.description:
                resultado_sp = cursor.fetchone()
                if resultado_sp:
                    error_formulario = resultado_sp[1] 
            else:
                mensaje_exito = None 
                
        except Exception as e:
            error_formulario = str(e)
            
    regalias = []
    total_ganado = 0.0
    total_reproducciones = 0

    with connection.cursor() as cursor:
        query_regalias = """
            SELECT 
                idRegalia,
                CONVERT(VARCHAR(10), fechaInicio, 23),
                CONVERT(VARCHAR(10), fechaFin, 23),
                totalReproducciones,
                montoTotal,
                CONVERT(VARCHAR(10), fechaPago, 23)
            FROM Operaciones.Regalia
            WHERE idArtista = %s
            ORDER BY fechaInicio DESC
        """
        cursor.execute(query_regalias, [id_artista])
        regalias = cursor.fetchall()

        for r in regalias:
            total_reproducciones += r[3]
            total_ganado += float(r[4])

    return render(request, 'viveec/regalias_artista.html', {
        'nombre': nombre_artista,
        'regalias': regalias,
        'total_ganado': total_ganado,
        'total_reproducciones': total_reproducciones,
        'error_formulario': error_formulario,
        'mensaje_exito': mensaje_exito
    })
    
def reportes_artista(request):
    nombre_artista = request.session.get('artista_nombre')
    
    id_artista = None
    with connection.cursor() as cursor:
        cursor.execute("SELECT idArtista FROM Musica.Artista WHERE nombreArtista = %s", [nombre_artista])
        res = cursor.fetchone()
        if res:
            id_artista = res[0]

    if not id_artista:
        return redirect('/login-artista/')

    datos_reproducciones = []
    datos_top_canciones = []
    oyentes_mensuales = 0
    pais_mas_escuchado = "N/A"
    oyentes_pais = 0

    lista_canciones_nombres = []
    lista_canciones_repros = []

    with connection.cursor() as cursor:
        cursor.execute("EXEC dbo.SP_ReproduccionesPorCancion %s", [id_artista])
        if cursor.description:
            datos_reproducciones = cursor.fetchall()
            for item in datos_reproducciones:
                lista_canciones_nombres.append(item[0]) 
                lista_canciones_repros.append(item[1])  

        cursor.execute("EXEC dbo.SP_TopCanciones %s", [id_artista])
        if cursor.description:
            datos_top_canciones = cursor.fetchall()

        cursor.execute("EXEC dbo.SP_OyentesMensuales %s", [id_artista])
        if cursor.description:
            res_oyentes = cursor.fetchone()
            if res_oyentes:
                oyentes_mensuales = res_oyentes[0]

        cursor.execute("EXEC dbo.SP_PaisMasEscuchado %s", [id_artista])
        if cursor.description:
            res_pais = cursor.fetchone()
            if res_pais:
                pais_mas_escuchado = res_pais[0]
                oyentes_pais = res_pais[1]

    return render(request, 'viveec/reportes_artista.html', {
        'nombre': nombre_artista,
        'datos_reproducciones': datos_reproducciones,
        'datos_top_canciones': datos_top_canciones,
        'oyentes_mensuales': oyentes_mensuales,
        'pais_mas_escuchado': pais_mas_escuchado,
        'oyentes_pais': oyentes_pais,
 
        'lista_canciones_nombres': lista_canciones_nombres,
        'lista_canciones_repros': lista_canciones_repros
    })

def reproducir_cancion_detalle(request, id_cancion):
    nombre_usuario = request.session.get('usuario_nombre')
    if not nombre_usuario:
        return redirect('/login-usuario/')
        
    cancion_info = None
    tiene_like = False

    with connection.cursor() as cursor:
        cursor.execute("SELECT IdUsuario FROM Usuarios.Usuario WHERE nombreUsuario = %s", [nombre_usuario])
        res_user = cursor.fetchone()
        id_usuario = res_user[0] if res_user else None

        if not id_usuario:
            return redirect('/dashboard-usuario/')

        query_cancion = """
            SELECT 
                MC.idCancion,
                MC.nombreCancion,
                MA.nombreArtista,
                MC.duracionCancion
            FROM Musica.Cancion MC
            INNER JOIN Musica.Album MB ON MC.idAlbum = MB.idAlbum
            INNER JOIN Musica.Artista MA ON MB.idArtista = MA.idArtista
            WHERE MC.idCancion = %s
        """
        cursor.execute(query_cancion, [id_cancion])
        fila = cursor.fetchone()
        
        if fila:
            cancion_info = {
                'id': fila[0],
                'nombre': fila[1],
                'artista': fila[2],
                'duracion': fila[3]
            }

            query_like = """
                SELECT 1 FROM Usuarios.LikeCancion 
                WHERE idCancion = %s AND IdUsuario = %s
            """
            cursor.execute(query_like, [id_cancion, id_usuario])
            if cursor.fetchone():
                tiene_like = True

    if not cancion_info:
        return redirect('/dashboard-usuario/')

    return render(request, 'viveec/reproductor_detalle.html', {
        'cancion': cancion_info,
        'nombre_usuario': nombre_usuario,
        'tiene_like': tiene_like
    })

@csrf_exempt
def alternar_like_cancion(request):
    if request.method == 'POST':
        nombre_usuario = request.session.get('usuario_nombre')
        if not nombre_usuario:
            return JsonResponse({'status': 'error', 'message': 'No autenticado'}, status=401)

        try:
            data = json.loads(request.body)
            id_cancion = data.get('idCancion')

            with connection.cursor() as cursor:
                cursor.execute("SELECT IdUsuario FROM Usuarios.Usuario WHERE nombreUsuario = %s", [nombre_usuario])
                res_user = cursor.fetchone()
                if not res_user:
                    return JsonResponse({'status': 'error', 'message': 'Usuario no encontrado'}, status=404)
                id_usuario = res_user[0]

                cursor.execute("""
                    SELECT 1 FROM Usuarios.LikeCancion 
                    WHERE idCancion = %s AND IdUsuario = %s
                """, [id_cancion, id_usuario])
                
                existe = cursor.fetchone()

                if existe:
                    cursor.execute("""
                        DELETE FROM Usuarios.LikeCancion 
                        WHERE idCancion = %s AND IdUsuario = %s
                    """, [id_cancion, id_usuario])
                    estado = 'removido'
                else:
                    cursor.execute("""
                        INSERT INTO Usuarios.LikeCancion (idCancion, IdUsuario) 
                        VALUES (%s, %s)
                    """, [id_cancion, id_usuario])
                    estado = 'agregado'

            return JsonResponse({'status': 'success', 'estado': estado})
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=400)

    return JsonResponse({'status': 'error', 'message': 'Método no permitido'}, status=405)

@csrf_exempt
def registrar_reproduccion(request):
    if request.method == 'POST':
        nombre_usuario = request.session.get('usuario_nombre')
        data = json.loads(request.body)
        id_cancion = data.get('idCancion')
        duracion_escuchada = int(data.get('tiempo'))

        with connection.cursor() as cursor:
            cursor.execute("SELECT IdUsuario, pais FROM Usuarios.Usuario WHERE nombreUsuario = %s", [nombre_usuario])
            res_user = cursor.fetchone()
            id_usuario, pais_usuario = res_user[0], res_user[1]

            cursor.execute("""
                EXEC SP_RegistrarReproduccion 
                @idCancion = %s, 
                @IdUsuario = %s, 
                @paisReproduccion = %s, 
                @duracion = %s
            """, [id_cancion, id_usuario, pais_usuario, duracion_escuchada])
            
        return JsonResponse({'status': 'success'})

def descubrir_albumes(request):
    nombre_usuario = request.session.get('usuario_nombre')
    if not nombre_usuario: return redirect('/login-usuario/')

    with connection.cursor() as cursor:
        cursor.execute("SELECT A.idAlbum, A.nombreAlbum, Art.nombreArtista FROM Musica.Album A JOIN Musica.Artista Art ON A.idArtista = Art.idArtista")
        albumes = [{'idAlbum': r[0], 'nombre': r[1], 'artista': {'nombre': r[2]}} for r in cursor.fetchall()]
        
        cursor.execute("SELECT idArtista, nombreArtista FROM Musica.Artista")
        artistas = [{'id': r[0], 'nombre': r[1]} for r in cursor.fetchall()]
        
    return render(request, 'viveec/descubrir.html', {
        'albumes': albumes,
        'artistas': artistas,
        'nombre': nombre_usuario
    })
    
def detalle_album(request, idAlbum):
    nombre_usuario = request.session.get('usuario_nombre')
    
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT A.nombreAlbum, Art.nombreArtista, YEAR(A.fechaLanzamientoAlbum), A.idAlbum
            FROM Musica.Album A
            JOIN Musica.Artista Art ON A.idArtista = Art.idArtista
            WHERE A.idAlbum = %s
        """, [idAlbum])
        info_album = cursor.fetchone()
        
        cursor.execute("SELECT IdUsuario FROM Usuarios.Usuario WHERE nombreUsuario = %s", [nombre_usuario])
        id_user = cursor.fetchone()[0]
        
        cursor.execute("SELECT 1 FROM Usuarios.AlbumGuardado WHERE idAlbum=%s AND IdUsuario=%s", [idAlbum, id_user])
        ya_agregado = cursor.fetchone() is not None
        
        cursor.execute("SELECT idCancion, nombreCancion, duracionCancion FROM Musica.Cancion WHERE idAlbum = %s", [idAlbum])
        canciones_raw = cursor.fetchall()
    
    canciones_procesadas = [
        {'id': c[0], 'nombre': c[1], 'duracion': f"{int(c[2])//60}:{int(c[2])%60:02d}"} 
        for c in canciones_raw
    ]
            
    return render(request, 'viveec/detalle_album.html', {
        'info_album': info_album, 
        'canciones': canciones_procesadas,
        'idAlbum': idAlbum,
        'ya_agregado': ya_agregado
    })

@csrf_exempt
def toggle_album(request):
    data = json.loads(request.body)
    id_album = data.get('idAlbum')
    nombre_usuario = request.session.get('usuario_nombre')
    
    with connection.cursor() as cursor:
        cursor.execute("SELECT IdUsuario FROM Usuarios.Usuario WHERE nombreUsuario = %s", [nombre_usuario])
        id_user = cursor.fetchone()[0]
        
        cursor.execute("SELECT 1 FROM Usuarios.AlbumGuardado WHERE idAlbum=%s AND IdUsuario=%s", [id_album, id_user])
        if cursor.fetchone():
            cursor.execute("DELETE FROM Usuarios.AlbumGuardado WHERE idAlbum=%s AND IdUsuario=%s", [id_album, id_user])
            estado = 'removido'
        else:
            cursor.execute("INSERT INTO Usuarios.AlbumGuardado (idAlbum, IdUsuario) VALUES (%s, %s)", [id_album, id_user])
            estado = 'agregado'
        connection.commit()
    return JsonResponse({'estado': estado})

def detalle_artista(request, idArtista):
    nombre_usuario = request.session.get('usuario_nombre')
    with connection.cursor() as cursor:
        cursor.execute("SELECT idArtista, nombreArtista FROM Musica.Artista WHERE idArtista = %s", [idArtista])
        art = cursor.fetchone()
        
        cursor.execute("SELECT IdUsuario FROM Usuarios.Usuario WHERE nombreUsuario = %s", [nombre_usuario])
        id_user = cursor.fetchone()[0]
        
        cursor.execute("SELECT 1 FROM Usuarios.SeguimientoArtistas WHERE idArtista=%s AND IdUsuario=%s", [idArtista, id_user])
        ya_sigue = cursor.fetchone() is not None

    return render(request, 'viveec/detalle_artista.html', {
        'artista': {'id': art[0], 'nombre': art[1]},
        'ya_sigue': ya_sigue
    })

@csrf_exempt
def toggle_seguir_artista(request):
    data = json.loads(request.body)
    id_artista = data.get('idArtista')
    nombre_usuario = request.session.get('usuario_nombre')
    
    with connection.cursor() as cursor:
        cursor.execute("SELECT IdUsuario FROM Usuarios.Usuario WHERE nombreUsuario = %s", [nombre_usuario])
        id_user = cursor.fetchone()[0]
        
        cursor.execute("SELECT 1 FROM Usuarios.SeguimientoArtistas WHERE idArtista=%s AND IdUsuario=%s", [id_artista, id_user])
        if cursor.fetchone():
            cursor.execute("DELETE FROM Usuarios.SeguimientoArtistas WHERE idArtista=%s AND IdUsuario=%s", [id_artista, id_user])
            estado = 'no_seguido'
        else:
            cursor.execute("INSERT INTO Usuarios.SeguimientoArtistas (idArtista, IdUsuario) VALUES (%s, %s)", [id_artista, id_user])
            estado = 'seguido'
        connection.commit()
    return JsonResponse({'estado': estado})

def biblioteca_usuario(request):
    nombre_usuario = request.session.get('usuario_nombre')
    
    if not nombre_usuario:
        return redirect('/login-usuario/')

    id_usuario = None
    with connection.cursor() as cursor:
        cursor.execute("SELECT IdUsuario FROM Usuarios.Usuario WHERE nombreUsuario = %s", [nombre_usuario])
        res = cursor.fetchone()
        if res:
            id_usuario = res[0]
    
    if not id_usuario:
        return redirect('/login-usuario/')

    mis_playlists = []
    comunidad_playlists = []

    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT idPlaylist, nombrePlaylist, visibilidad 
            FROM Usuarios.Playlist 
            WHERE idUsuarioPropietario = %s
        """, [id_usuario])
        for fila in cursor.fetchall():
            mis_playlists.append({
                'idPlaylist': fila[0],
                'nombrePlaylist': fila[1],
                'visibilidad': fila[2]
            })

        cursor.execute("""
            SELECT P.idPlaylist, P.nombrePlaylist, U.nombreUsuario 
            FROM Usuarios.Playlist P
            JOIN Usuarios.Usuario U ON P.idUsuarioPropietario = U.IdUsuario
            WHERE P.visibilidad = 'Pública' AND P.idUsuarioPropietario != %s
        """, [id_usuario])
        for fila in cursor.fetchall():
            comunidad_playlists.append({
                'idPlaylist': fila[0],
                'nombrePlaylist': fila[1],
                'propietario': fila[2]
            })

    return render(request, 'viveec/biblioteca_usuario.html', {
        'nombre': nombre_usuario,
        'mis_playlists': mis_playlists,
        'comunidad_playlists': comunidad_playlists
    })


def playlist_detalle(request, idPlaylist):
    nombre_usuario = request.session.get('usuario_nombre')
    if not nombre_usuario:
        return redirect('/login-usuario/')

    id_usuario_actual = request.session.get('usuario_id')
    
    with connection.cursor() as cursor:
        if not id_usuario_actual:
            cursor.execute("SELECT IdUsuario FROM Usuarios.Usuario WHERE nombreUsuario = %s", [nombre_usuario])
            row = cursor.fetchone()
            if row:
                id_usuario_actual = row[0]
                request.session['usuario_id'] = id_usuario_actual

        cursor.execute("""
            SELECT P.idPlaylist, P.nombrePlaylist, U.nombreUsuario, P.idUsuarioPropietario 
            FROM Usuarios.Playlist P
            JOIN Usuarios.Usuario U ON P.idUsuarioPropietario = U.IdUsuario
            WHERE P.idPlaylist = %s
        """, [idPlaylist])
        res = cursor.fetchone()
        
        playlist = {}
        es_propietario = False
        ya_guardado = False
        
        if res:
            playlist = {
                'idPlaylist': res[0],
                'nombrePlaylist': res[1],
                'propietario': {'nombre': res[2]},
                'idUsuarioPropietario': res[3]
            }
            es_propietario = (str(res[3]).strip() == str(id_usuario_actual).strip())

            cursor.execute("""
                SELECT 1 FROM Usuarios.PlaylistUsuarioColaborador 
                WHERE idPlaylist=%s AND IdUsuarioColaborador=%s
            """, [idPlaylist, id_usuario_actual])
            if cursor.fetchone():
                ya_guardado = True

        canciones = []
        cursor.execute("""
            SELECT C.idCancion, C.nombreCancion, C.duracionCancion 
            FROM Musica.Cancion C
            JOIN Usuarios.PlaylistCancion PC ON C.idCancion = PC.idCancion
            WHERE PC.idPlaylist = %s
        """, [idPlaylist])
        for fila in cursor.fetchall():
            canciones.append({'id': fila[0], 'nombre': fila[1], 'duracion': fila[2]})

        cursor.execute("SELECT idCancion, nombreCancion FROM Musica.Cancion")
        todas_las_canciones = [{'id': row[0], 'nombre': row[1]} for row in cursor.fetchall()]

    return render(request, 'viveec/playlist_detalle.html', {
        'playlist': playlist,
        'canciones': canciones,
        'todas_las_canciones': todas_las_canciones, 
        'nombre': nombre_usuario,
        'es_propietario': es_propietario,
        'ya_guardado': ya_guardado
    })
    
def crear_playlist(request):
    if request.method == 'POST':
        nombre = request.POST.get('nombre')
        descripcion = request.POST.get('descripcion')
        visibilidad = request.POST.get('visibilidad')
        
        nombre_usuario = request.session.get('usuario_nombre')

        if not nombre_usuario:
            return redirect('/') 

        with connection.cursor() as cursor:
            cursor.execute("SELECT IdUsuario FROM Usuarios.Usuario WHERE nombreUsuario = %s", [nombre_usuario])
            usuario_row = cursor.fetchone()
            
            if not usuario_row:
                return redirect('/') 
            
            id_usuario = usuario_row[0]

            cursor.execute("SELECT TOP 1 idPlaylist FROM Usuarios.Playlist ORDER BY idPlaylist DESC")
            ultimo = cursor.fetchone()
            
            if ultimo and ultimo[0]:
                numero = int(ultimo[0][1:]) + 1
                nuevo_id = f"P{numero:03d}"
            else:
                nuevo_id = "P001"
            
            cursor.execute("""
                INSERT INTO Usuarios.Playlist (idPlaylist, nombrePlaylist, descripcionPlaylist, visibilidad, idUsuarioPropietario)
                VALUES (%s, %s, %s, %s, %s)
            """, [nuevo_id, nombre, descripcion, visibilidad, id_usuario])
            
        return redirect('/biblioteca-usuario/')
    
    return redirect('/biblioteca-usuario/')

@csrf_exempt
def toggle_playlist(request):
    data = json.loads(request.body)
    id_playlist = data.get('idPlaylist')
    nombre_usuario = request.session.get('usuario_nombre')
    
    with connection.cursor() as cursor:
        cursor.execute("SELECT IdUsuario FROM Usuarios.Usuario WHERE nombreUsuario = %s", [nombre_usuario])
        id_user = cursor.fetchone()[0]
        
        cursor.execute("""
            SELECT 1 FROM Usuarios.PlaylistUsuarioColaborador 
            WHERE idPlaylist=%s AND IdUsuarioColaborador=%s
        """, [id_playlist, id_user])
        
        if cursor.fetchone():
            cursor.execute("""
                DELETE FROM Usuarios.PlaylistUsuarioColaborador 
                WHERE idPlaylist=%s AND IdUsuarioColaborador=%s
            """, [id_playlist, id_user])
            estado = 'no_guardado'
        else:
            cursor.execute("""
                INSERT INTO Usuarios.PlaylistUsuarioColaborador (idPlaylist, IdUsuarioColaborador) 
                VALUES (%s, %s)
            """, [id_playlist, id_user])
            estado = 'guardado'
        
    return JsonResponse({'estado': estado})

def buscar_canciones(request):
    query = request.GET.get('q', '')
    with connection.cursor() as cursor:
        cursor.execute("SELECT idCancion, nombreCancion FROM Musica.Cancion WHERE nombreCancion LIKE %s LIMIT 5", [f'%{query}%'])
        canciones = [{'id': row[0], 'nombre': row[1]} for row in cursor.fetchall()]
    return JsonResponse({'canciones': canciones})

@csrf_exempt
def agregar_cancion_a_playlist(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        with connection.cursor() as cursor:
            cursor.execute("INSERT INTO Usuarios.PlaylistCancion (idPlaylist, idCancion) VALUES (%s, %s)", 
                           [data['idPlaylist'], data['idCancion']])
            connection.commit()
        return JsonResponse({'status': 'ok'})

@csrf_exempt
def eliminar_cancion(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        with connection.cursor() as cursor:
            cursor.execute("DELETE FROM Usuarios.PlaylistCancion WHERE idPlaylist = %s AND idCancion = %s", 
                           [data['idPlaylist'], data['idCancion']])
            connection.commit()
        return JsonResponse({'status': 'eliminado'})
    
def suscripcion_usuario(request):
    nombre_usuario = request.session.get('usuario_nombre')
    
    id_usuario = None
    suscripcion_actual = None
    historial_pagos = []
    
    with connection.cursor() as cursor:
        cursor.execute("SELECT IdUsuario FROM Usuarios.Usuario WHERE nombreUsuario = %s", [nombre_usuario])
        res = cursor.fetchone()
        if res:
            id_usuario = res[0]
            
            cursor.execute("""
                SELECT tipoSuscripcion 
                FROM Operaciones.Suscripcion 
                WHERE idUsuario = %s 
                AND estadoSuscripcion = 'Activa' 
                AND GETDATE() <= fechaFinSuscripcion
            """, [id_usuario])
            suscripcion_actual = cursor.fetchone()
            
            cursor.execute("""
                SELECT 
                    S.tipoSuscripcion, 
                    P.monto, 
                    S.fechaInicioSuscripcion, 
                    S.fechaFinSuscripcion 
                FROM Operaciones.Pago P
                JOIN Operaciones.Suscripcion S ON P.idSuscripcion = S.idSuscripcion
                WHERE S.idUsuario = %s
                ORDER BY S.fechaInicioSuscripcion DESC
            """, [id_usuario])
            historial_pagos = cursor.fetchall()
            
    if not id_usuario:
        return redirect('/login-usuario/')

    error_formulario = None

    if request.method == 'POST' and not suscripcion_actual:
        tipo = request.POST.get('tipoSuscripcion')
        monto = request.POST.get('monto')
        metodo = request.POST.get('metodoPago')

        with connection.cursor() as cursor:
            cursor.execute("SELECT TOP 1 idSuscripcion FROM Operaciones.Suscripcion ORDER BY idSuscripcion DESC")
            res_s = cursor.fetchone()
            nuevo_id_s = f'S{int(res_s[0][1:]) + 1:03}' if res_s else 'S001'

            cursor.execute("SELECT TOP 1 idPago FROM Operaciones.Pago ORDER BY idPago DESC")
            res_p = cursor.fetchone()
            nuevo_id_p = f'P{int(res_p[0][1:]) + 1:03}' if res_p else 'P001'

            try:
                cursor.execute("""
                    EXEC SP_CrearSuscripcion %s, %s, %s, %s, %s, %s, 'Aprobado'
                """, [nuevo_id_s, nuevo_id_p, id_usuario, tipo, monto, metodo])
                return redirect('/suscripcion-usuario/')
            except Exception as e:
                error_formulario = str(e)

    return render(request, 'viveec/suscripcion.html', {
        'nombre': nombre_usuario,
        'tiene_suscripcion': suscripcion_actual is not None,
        'nombre_plan': suscripcion_actual[0] if suscripcion_actual else None,
        'error_formulario': error_formulario,
        'planes': [('Individual', '9.99'), ('Estudiante', '4.99'), ('Familiar', '14.99')],
        'historial_pagos': historial_pagos
    })

def formatear_tiempo(segundos):
    if not segundos:
        return "0:00"

    minutos = int(segundos) // 60
    segundos_restantes = int(segundos) % 60

    return f"{minutos}:{segundos_restantes:02d}"

def reportes_usuario(request):
    nombre_usuario = request.session.get('usuario_nombre')
    id_usuario = None
    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT IdUsuario FROM Usuarios.Usuario WHERE nombreUsuario = %s",
            [nombre_usuario]
        )
        res = cursor.fetchone()
        if res:
            id_usuario = res[0]
        else:
            return redirect('/login-usuario/')
    data = {
        'nombre': nombre_usuario
    }
    with connection.cursor() as cursor:
        cursor.execute(
            "EXEC SP_TopCancionesMasEscuchadas %s",
            [id_usuario]
        )
        top_canciones = cursor.fetchall()
        data['top_canciones'] = top_canciones
        data['nombres_canciones'] = [x[0] for x in top_canciones]
        data['repros_canciones'] = [x[1] for x in top_canciones]
        cursor.execute(
            "EXEC SP_GenerosMusicalesFavoritos %s",
            [id_usuario]
        )
        generos_data = cursor.fetchall()
        data['generos_tabla'] = generos_data
        cursor.execute(
            "EXEC SP_TiempoEscuchaPorMes %s",
            [id_usuario]
        )
        res_mes = cursor.fetchone()
        segundos_mes = res_mes[0] if res_mes else 0
        data['tiempo_mes'] = formatear_tiempo(segundos_mes)
        cursor.execute(
            "EXEC SP_TiempoEscuchaPorSemana %s",
            [id_usuario]
        )
        res_sem = cursor.fetchone()
        segundos_semana = res_sem[0] if res_sem else 0
        data['tiempo_semana'] = formatear_tiempo(segundos_semana)
        cursor.execute(
            "EXEC SP_ArtistasMasEscuchadosDelMes %s",
            [id_usuario]
        )
        artistas_raw = cursor.fetchall()
        artistas_formateados = []
        for artista in artistas_raw:
            artistas_formateados.append(
                (
                    artista[0],
                    formatear_tiempo(artista[1])
                )
            )
        data['artistas_top'] = artistas_formateados
        cursor.execute(
            "EXEC SP_HistorialDeReproducciones %s",
            [id_usuario]
        )
        historial_raw = cursor.fetchall()
        historial_formateado = []
        for h in historial_raw:
            historial_formateado.append(
                (
                    h[0],
                    formatear_tiempo(h[1]),
                    h[2]
                )
            )
        data['historial'] = historial_formateado
        cursor.execute(
            "EXEC SP_CancionesConLike %s",
            [id_usuario]
        )
        data['likes'] = [x[0] for x in cursor.fetchall()]
    return render(
        request,
        'viveec/reportes_usuario.html',
        data
    )
