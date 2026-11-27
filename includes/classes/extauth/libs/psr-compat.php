<?php
/**
 * Puente de compatibilidad PSR-17
 * Declara las interfaces en el namespace antiguo (Psr\Http\Message)
 * extendiendo las del namespace nuevo (Psr\Http\Factory)
 */

namespace Psr\Http\Message;

if (!interface_exists('Psr\Http\Message\RequestFactoryInterface', false)) {
    interface RequestFactoryInterface extends \Psr\Http\Factory\RequestFactoryInterface {}
}
if (!interface_exists('Psr\Http\Message\ResponseFactoryInterface', false)) {
    interface ResponseFactoryInterface extends \Psr\Http\Factory\ResponseFactoryInterface {}
}
if (!interface_exists('Psr\Http\Message\ServerRequestFactoryInterface', false)) {
    interface ServerRequestFactoryInterface extends \Psr\Http\Factory\ServerRequestFactoryInterface {}
}
if (!interface_exists('Psr\Http\Message\StreamFactoryInterface', false)) {
    interface StreamFactoryInterface extends \Psr\Http\Factory\StreamFactoryInterface {}
}
if (!interface_exists('Psr\Http\Message\UploadedFileFactoryInterface', false)) {
    interface UploadedFileFactoryInterface extends \Psr\Http\Factory\UploadedFileFactoryInterface {}
}
if (!interface_exists('Psr\Http\Message\UriFactoryInterface', false)) {
    interface UriFactoryInterface extends \Psr\Http\Factory\UriFactoryInterface {}
}