describe('Rotas Pedido', () => {

    let idCaixa: number;
    let idCliente: number;
    let idCliente2: number;
    let idEndereco: number;
    let idEndereco2: number;
    let idTipoPgto: number;
    let idTipoPgto2: number;
    let idPedido:number;
    let idPedido2:number;

    before(() => {
        cy.request({
            method: 'POST',
            url: '/caixas',
            body: {
                "id": 0,
                "total": 0.00,
                "aberto": true
            },
            failOnStatusCode: false
        }).then((Response) => {
            idCaixa = Response.body[1].id;
        });

        cy.request({
            method: 'POST',
            url: '/clientes',
            body: {
                "nome": "Priscila G. Vieira",
                "contato": "55229785634"
            },
            failOnStatusCode: false
        }).then((Response) => {
            idCliente = Response.body[1].id;
        });
        
        cy.request({
            method: 'POST',
            url: '/clientes',
            body: {
                "nome": "Diego Ferreira",
                "contato": "5522988667744"
            },
            failOnStatusCode: false
        }).then((Response) => {
            idCliente2 = Response.body[1].id;
        });
        
        cy.request({
            method: 'POST',
            url: '/clientes/55229785634/enderecos',
            body: {
                "id": 0,
                "cliente": idCliente,
                "rua": "Av. Country Clube dos Engenheiros",
                "numero": "2042",
                "bairro": "Clube dos Engenheiros",
                "complemento": "Casa 120",
                "cidade": "Araruama",
                "estado": "RJ"
            },
            failOnStatusCode: false
        }).then((Response) => {
            idEndereco = Response.body[1].id;
        });
        
        cy.request({
            method: 'POST',
            url: '/clientes/55229785634/enderecos',
            body: {
                "id": idCliente2,
                "rua": "rua Érica Reis",
                "numero": "35",
                "bairro": "Outeiro",
                "complemento": "Casa 4",
                "cidade": "Belford Roxo",
                "estado": "RJ"
            },
            failOnStatusCode: false
        }).then((Response) => {
            idEndereco2 = Response.body[1].id;
        });
        
        cy.request({
            method: 'POST',
            url: '/tipo-pagamento',
            body: {
                "id": 0,
                "descricao": "dinheiro",
            },
            failOnStatusCode: false
        }).then((Response) => {
            idTipoPgto = Response.body[1].id;
        });
        
        cy.request({
            method: 'POST',
            url: '/tipo-pagamento',
            body: {
                "id": 0,
                "descricao": "débito",
            },
            failOnStatusCode: false
        }).then((Response) => {
            idTipoPgto2 = Response.body[1].id;
        });
    });

    it('Criar Pedido - 01', () => {
        cy.request({
            method: 'POST',
            url: '/pedidos',
            body: {
                "id": 0,
                "total": 0.00,
                "aberto": true,
                "cancelado": false,
                "obs":"",
                "cliente": {
                    "id":idCliente,
                    "nome": "Priscila G. Vieira",
                    "contato": "55229785634"
                },
                "endereco_entrega":
                {
                    "id": idEndereco,
                    "cliente": idCliente,
                    "rua": "Av. Country Clube dos Engenheiros",
                    "numero": "2042",
                    "bairro": "Clube dos Engenheiros",
                    "complemento": "Casa 120",
                    "cidade": "Araruama",
                    "estado": "RJ"
                },
                "tipo_pagamento": {
                    "id": idTipoPgto,
                    "descricao":"dinheiro"
                },
                "caixa": {
                    "id": idCaixa,
                    "total": 0.00,
                    "aberto": true
                },
            }
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].message).to.equal('Pedido adicionado com sucesso!');
            expect(Response.body[1].cliente.id).to.equal(idCliente);
            expect(Response.body[1].endereco_entrega.id).to.equal(idEndereco);
            expect(Response.body[1].tipo_pagamento.id).to.equal(idTipoPgto);
            expect(Response.body[1].caixa.id).to.equal(idCaixa);
            idPedido = Response.body[1].id;
        });
    });

    it('Criar Pedido - 02', () => {
        cy.request({
            method: 'POST',
            url: '/pedidos',
            body: {
                "id": 0,
                "total": 0.00,
                "aberto":true,
                "cancelado": false,
                "obs":"",
                "cliente": idCliente2,
                "endereco_entrega": idEndereco2,
                "tipo_pagamento":  idTipoPgto2,
                "caixa": idCaixa,
            }
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].message).to.equal('Pedido adicionado com sucesso!');
            expect(Response.body[1].cliente.id).to.equal(idCliente2);
            expect(Response.body[1].endereco_entrega.id).to.equal(idEndereco2);
            expect(Response.body[1].tipo_pagamento.id).to.equal(idTipoPgto2);
            expect(Response.body[1].caixa.id).to.equal(idCaixa);
            idPedido2 = Response.body[1].id;
        });
    });

    it('Buscar pedidos por caixa', () => {
        cy.request(`/caixa/${idCaixa}/pedidos`)
            .then((Response) => {
                expect(Response.status).to.equal(200);
                Response.body.forEach((pedido:any) => {
                    expect(pedido.caixa.id).to.equal(idCaixa);                    
                });
            });
    });
    
    it('Buscar pedidos cancelados', () => {
        cy.request(`/caixa/${idCaixa}/pedidos`)
            .then((Response) => {
                expect(Response.status).to.equal(200);
                Response.body.forEach((pedido:any) => {
                    expect(pedido.caixa.id).to.equal(idCaixa);                    
                    expect(pedido.aberto).to.equal(false);
                    expect(pedido.cancelado).to.equal(true);
                });
            });
    });
    
    it('Buscar pedidos abertos', () => {
        cy.request(`/caixa/${idCaixa}/pedidos`)
            .then((Response) => {
                expect(Response.status).to.equal(200);
                Response.body.forEach((pedido: any) => {
                    expect(pedido.caixa.id).to.equal(idCaixa);                   
                    expect(pedido.aberto).to.equal(true);
                    expect(pedido.cancelado).to.equal(false);                    
                });
            });
    });

    it('Buscar pedido por id 1', () => {
        cy.request(`/pedido/${idPedido}`).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.id).to.equal(idPedido);
        });
    });

    it('Buscar pedido por id 2', () => {
        cy.request(`/pedido/${idPedido2}`).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.id).to.equal(idPedido2);
        });
    });

    it('Update pedido cancelado', () => {
        cy.request({
            method: 'PUT',
            url: `/caixa/${idCaixa}/pedidos/${idPedido}`,
            body: {
                "id": idPedido,
                "cancelado": true,
                "obs":"Por que eu quis"
            }
        }).then(Response => {
            expect(Response.status).to.equal(200);
            expect(Response.body[0].message).to.equal('Pedido cancelado!');
            expect(Response.body[1].cancelado).to.equal(true);
            expect(Response.body[1].aberto).to.equal(false);
        });
    });

    it('Update pedido fechar conta', () => {
        cy.request({
            method: 'PUT',
            url: `/caixa/${idCaixa}/pedidos/${idPedido2}`,
            body: {
                "id": idPedido2,
                "total": 0.00,
                "aberto":true,
                "cancelado": false,
                "obs":"",
                "cliente": idCliente2,
                "endereco_entrega": idEndereco2,
                "tipo_pagamento":  idTipoPgto2,
                "caixa": idCaixa,
            }
        }).then(Response => {
            expect(Response.status).to.equal(200);
            expect(Response.body[0].message).to.equal('Pedido fechado!');
            expect(Response.body[1].cancelado).to.equal(false);
            expect(Response.body[1].aberto).to.equal(true);
        });
    });

    after(() => {
        cy.request({
            method: 'DELETE',
            url: `/clientes/${idCliente}`,
            failOnStatusCode: false
        });

        cy.request({
            method: 'DELETE',
            url: `/clientes/${idCliente2}`,
            failOnStatusCode: false
        });
    });

});