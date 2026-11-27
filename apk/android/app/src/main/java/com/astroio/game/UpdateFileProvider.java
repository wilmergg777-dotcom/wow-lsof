package com.astroio.game;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.database.Cursor;
import android.database.MatrixCursor;
import android.net.Uri;
import android.os.ParcelFileDescriptor;
import android.provider.OpenableColumns;

import java.io.File;
import java.io.FileNotFoundException;

/**
 * AstroIO — proveedor propio (sin androidx) que entrega el APK de
 * actualización descargado al instalador del sistema.
 */
public class UpdateFileProvider extends ContentProvider {

    public static final String AUTHORITY = "com.astroio.game.update";
    public static final String APK_FILE_NAME = "astroio_update.apk";

    @Override
    public boolean onCreate() {
        return true;
    }

    private static File apkFile(android.content.Context ctx) {
        return new File(ctx.getFilesDir(), APK_FILE_NAME);
    }

    @Override
    public ParcelFileDescriptor openFile(Uri uri, String mode) throws FileNotFoundException {
        File f = apkFile(getContext());
        return ParcelFileDescriptor.open(f, ParcelFileDescriptor.parseMode(mode));
    }

    @Override
    public Cursor query(Uri uri, String[] projection, String selection,
                        String[] selectionArgs, String sortOrder) {
        if (projection == null) {
            projection = new String[] { OpenableColumns.DISPLAY_NAME, OpenableColumns.SIZE };
        }
        File f = apkFile(getContext());
        MatrixCursor cursor = new MatrixCursor(projection);
        Object[] row = new Object[projection.length];
        for (int i = 0; i < projection.length; i++) {
            if (OpenableColumns.DISPLAY_NAME.equals(projection[i])) {
                row[i] = APK_FILE_NAME;
            } else if (OpenableColumns.SIZE.equals(projection[i])) {
                row[i] = f.exists() ? f.length() : 0L;
            } else {
                row[i] = null;
            }
        }
        cursor.addRow(row);
        return cursor;
    }

    @Override
    public String getType(Uri uri) {
        return "application/vnd.android.package-archive";
    }

    @Override
    public Uri insert(Uri uri, ContentValues values) {
        return null;
    }

    @Override
    public int delete(Uri uri, String selection, String[] selectionArgs) {
        return 0;
    }

    @Override
    public int update(Uri uri, ContentValues values, String selection, String[] selectionArgs) {
        return 0;
    }
}
