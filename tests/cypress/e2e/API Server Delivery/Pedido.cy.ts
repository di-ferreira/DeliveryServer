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

    it('Buscar pedidos', () => {
        cy.request(`/caixa/${idCaixa}/pedidos`)
            .then((Response) => {
                expect(Response.status).to.equal(200);
                expect(Response.body.contato).to.equal('55229785634');
                expect(Response.body.enderecos[0].rua).to.equal('Av. Country Clube dos Engenheiros');
                expect(Response.body.enderecos[1].rua).to.equal('rua Érica Reis');
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

    // it('Update endereço - 01', () => {
    //     cy.request({
    //         method: 'PUT',
    //         url: `/clientes/55229785634/enderecos/${idEndereco01}`,
    //         body: {
    //             "id": 1,
    //             "rua": "rua dos Gaúchos",
    //             "numero": "200",
    //             "bairro": "Vila Capri",
    //             "complemento": "",
    //             "cidade": "Araruama",
    //             "estado": "RJ"
    //         }
    //     }).then(Response => {
    //         expect(Response.status).to.equal(200);
    //         expect(Response.body[0].message).to.equal('Endereço atualizado com sucesso!');
    //         expect(Response.body[1].rua).to.equal('rua dos Gaúchos');
    //         expect(Response.body[1].bairro).to.equal('Vila Capri');
    //         expect(Response.body[1].cidade).to.equal('Araruama');
    //     });
    // });

    // it('Update endereço - 02', () => {
    //     cy.request({
    //         method: 'PUT',
    //         url: `/enderecos/${idEndereco02}`,
    //         body: {
    //             "id": 2,
    //             "rua": "rua Nosso Senhor do Calvário",
    //             "numero": "69",
    //             "bairro": "Parque Amorim",
    //             "complemento": "",
    //             "cidade": "Belford Roxo",
    //             "estado": "RJ"
    //         }
    //     }).then(Response => {
    //         expect(Response.status).to.equal(200);
    //         expect(Response.body[0].message).to.equal('Endereço atualizado com sucesso!');
    //         expect(Response.body[1].rua).to.equal('rua Nosso Senhor do Calvário');
    //         expect(Response.body[1].bairro).to.equal('Parque Amorim');
    //         expect(Response.body[1].cidade).to.equal('Belford Roxo');
    //     });
    // });


    // it('Delete endereço 01', () => {
    //     cy.request({
    //         method: 'DELETE',
    //         url: `/clientes/55229785634/enderecos/${idEndereco01}`
    //     }).then(Response => {
    //         expect(Response.status).to.equal(202);
    //         expect(Response.body.message).to.equal('Endereço excluído!');
    //     });
    // });

    // it('Delete endereço 02', () => {
    //     cy.request({
    //         method: 'DELETE',
    //         url: `/enderecos/${idEndereco02}`
    //     }).then(Response => {
    //         expect(Response.status).to.equal(202);
    //         expect(Response.body.message).to.equal('Endereço excluído!');
    //     });
    // });

    // after(() => {
    //     cy.request({
    //         method: 'DELETE',
    //         url: '/clientes/55229785634',
    //         failOnStatusCode: false
    //     });
    // });

});