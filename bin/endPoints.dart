import 'dart:collection';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:supabase/supabase.dart';

import 'cryptography.dart';

class EndPoints {
  final Cryptography crypto = Cryptography();

  final client = SupabaseClient('INFORME_A_URL_DO_SUPABASE', 'INSIRA_A_SUA_SUPABASE_KEY');

  Handler get handler {
    final router = Router(
        notFoundHandler: (Request request) =>
            Response.notFound(
                'We dont have an API for this request'
            )
    );

    /// start Users endPoints

    /// List all users
    router.get('/users/listAll', (Request request) async {
      final res = await client
          .from('users')
          .select()
          .execute();

      if(res.error!=null) {
        return Response.notFound(
            jsonEncode({
              res.error!.message
            }),
            headers: {'Content-type':'application/json'}
        );
      }

      return Response.ok(
          jsonEncode(res.data),
          headers: {'Content-type':'application/json'}
      );
    });

    /// Insert new user
    router.post('/users/insert', (Request request) async {
      final payload = jsonDecode(await request.readAsString());

      if(payload.containsKey('name') && payload.containsKey('password')) {

        var password = crypto.encrypt(payload['password']);

        final res = await client
            .from('users')
            .insert([
          {"name": payload['name'], "password": password}
        ]).execute();

        if(res.error!=null) {
          return Response.notFound(
              jsonEncode(
                  {'success':false, 'data': res.error!.message,}
              ),
              headers: {'Content-type':'application/json'}
          );
        }

        return Response.ok(
          jsonEncode({
            'success':true,
            'data':res.data
          }),
          headers: {'Content-type':'application/json'},
        );
      }

      return Response.notFound(
          jsonEncode(
              {'success':false, 'data':'Invalid data sent to API',}
          ),
          headers: {'Content-type':'application/json'}
      );

    });

    /// Read user data with id
    router.get('/users/<id>', (Request request,String id) async {
      final res = await client
          .from('users')
          .select()
          .match({'id':id})
          .execute() ;

      // res.data is null if we pass a string as ID eg: 11a
      if(res.data == null) {
        return Response.notFound(
            jsonEncode({
              'success':false,
              'data':'Invalid ID'
            }),
            headers: {'Content-type':'application/json'}
        );
      }

      // res.data.length is 0 if an entry with given ID is not present
      if(res.data.length!=0) {
        final result = {
          'success':true,
          'data':res.data
        };

        return Response.ok(
            jsonEncode(result),
            headers: {'Content-type':'application/json'}
        );
      }
      else {
        return Response.notFound(
            jsonEncode({
              'success':false,
              'data':'No data available for selected ID'
            }),
            headers: {'Content-type':'application/json'}
        );
      }
    });

    /// Update user using Id
    router.put('/users/update/<id>', (Request request,String id) async {
      final payload = jsonDecode(await request.readAsString());

      if(payload.containsKey('password')) {
        var password = crypto.encrypt(payload['password']);
        payload['password'] = password;
      }

      final res = await client
          .from('users')
          .update(payload)
          .match({ 'id': id })
          .execute();

      if(res.data!=null) {
        final result = {
          'success':true,
          'data':res.data
        };

        return Response.ok(
            jsonEncode(result),
            headers: {'Content-type':'application/json'}
        );
      }
      else if(res.error!=null) {
        if(res.error!.message.toString() == '[]') {
          return Response.notFound(
              jsonEncode({
                'success':false,
                'data':'Id does not exist',
              }),
              headers: {'Content-type':'application/json'}
          );
        }

        return Response.notFound(
            jsonEncode({
              'success':false,
              'data':res.error!.message,
            }),
            headers: {'Content-type':'application/json'}
        );
      }
    });

    /// Delete a user using ID
    router.delete('/users/delete/<id>', (Request request,String id) async {
      final res = await client
          .from('users')
          .delete()
          .match({'id':id})
          .execute();

      if(res.data!=null) {
        if(res.data.toString() == '[]') {
          return Response.notFound(
              jsonEncode({
                'success':false,
                'data':'Id not found'
              }),
              headers: {'Content-type':'application/json'}
          );
        }
        final result = {
          'success':true,
          'data':res.data
        };

        return Response.ok(
            jsonEncode(result),
            headers: {'Content-type':'application/json'}
        );
      }

      else if(res.error!=null) {
        if(res.error!.message.toString() == '[]') {
          return Response.notFound(
              jsonEncode({
                'success':false,
                'data':'Id does not exist',
              }),
              headers: {'Content-type':'application/json'}
          );
        }

        return Response.notFound(
            jsonEncode({
              'success':false,
              'data':res.error!.message,
            }),
            headers: {'Content-type':'application/json'}
        );
      }
    });

    /// Read user data with Login name and password
    router.post('/login', (Request request) async {
      final payload = jsonDecode(await request.readAsString());

      var password = crypto.encrypt(payload['password']);

      final res = await client
          .from('users')
          .select('id')
          .eq('name', payload['name']).eq('password', password)
          .execute() ;

      // res.data is null if we pass a string as ID eg: 11a
      if(res.data == null) {
        return Response.notFound(
            jsonEncode({
              'success': false,
              'idUser': 0
            }),
            headers: {'Content-type':'application/json'}
        );
      }

      if(res.data.length!=0) {
        Map<String, dynamic> resultJSon = res.data[0];

        final result = {
          'success':true,
          'idUser': resultJSon["id"]
        };

        return Response.ok(
            jsonEncode(result),
            headers: {'Content-type':'application/json'}
        );
      }
      else {
        return Response.notFound(
            jsonEncode({
              'success': false,
              'idUser': 0
            }),
            headers: {'Content-type':'application/json'}
        );
      }
    });

    /// end Users endPoints

    /// start Patrimony endPoints

    /// Read all
    router.get('/patrimony/listAll', (Request request) async {
      final res = await client
          .from('patrimony')
          .select()
          .execute();

      if(res.error!=null) {
        return Response.notFound(
            jsonEncode({
              res.error!.message
            }),
            headers: {'Content-type':'application/json'}
        );
      }

      return Response.ok(
          jsonEncode(res.data),
          headers: {'Content-type':'application/json'}
      );
    });

    /// end Patrimony endPoints

    /// start Inspection endPoints

    /// Read all inspections
    router.get('/inspection/listAllByPatrimonyId/<patrimonyId>', (Request request, String patrimonyId) async {

      final res = await client
          .from('inspections')
          .select("*, photo_rel_inspection(*)")
          .eq('patrimonyId', patrimonyId)
          .execute();

      if(res.error!=null) {
        return Response.notFound(
            jsonEncode({
              res.error!.message
            }),
            headers: {'Content-type':'application/json'}
        );
      }

      return Response.ok(
          jsonEncode(res.data),
          headers: {'Content-type':'application/json'}
      );
    });

    /// insert a new inspection
    router.post('/inspection/insert', (Request request) async {
      final payload = jsonDecode(await request.readAsString());

      if(payload.containsKey('patrimonyId') &&
         payload.containsKey('inspectorId') &&
         payload.containsKey('res1') &&
         payload.containsKey('res2') &&
         payload.containsKey('res3') &&
         payload.containsKey('res4') &&
         payload.containsKey('res5')
      ) {

        final res = await client
            .from('inspections')
            .insert([
          { "patrimonyId": payload['patrimonyId'],
            "inspectorId": payload['inspectorId'],
            "date": payload['date'],
            "comments": payload['comments'],
            "offline": payload['offline'],
            "res1": payload['res1'],
            "res2": payload['res2'],
            "res3": payload['res3'],
            "res4": payload['res4'],
            "res5": payload['res5'],
          }
        ]).execute();

        if(res.error!=null) {
          return Response.notFound(
              jsonEncode(
                  {'success':false, 'data': res.error!.message,}
              ),
              headers: {'Content-type':'application/json'}
          );
        }

        if(res.data.length!=0 && payload.containsKey('photos')) {
          Map<String, dynamic> resultJSon = res.data[0];

          List<dynamic> photos = payload["photos"];

          for (int nPhoto = 0; nPhoto < photos.length; nPhoto++) {
            final resPhoto = await client
                .from('photo_rel_inspection')
                .insert([
            { "inspectionId": resultJSon['id'],
            "urlPhoto": photos[nPhoto]["urlPhoto"]
            }
            ]).execute();
          }
        }

        return Response.ok(
          jsonEncode({
            'success':true,
            'data':res.data
          }),
          headers: {'Content-type':'application/json'},
        );
      }

      return Response.notFound(
          jsonEncode(
              {'success':false, 'data':'Invalid data sent to API',}
          ),
          headers: {'Content-type':'application/json'}
      );

    });

    /// end Inspections endPoints

    return router;
  }

}
